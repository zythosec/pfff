(* Yoann Padioleau
 *
 * Copyright (C) 2012 Facebook
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)
open Common

module E = Database_code
module G = Graph_code

open Ast_ml
module V = Visitor_ml
module Ast = Ast_ml

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(*
 * Graph of dependencies for OCaml. See graph_code.ml and main_codegraph.ml
 * for more information.
 * 
 * todo? if give edges a weight, then we need to modulate it depending on
 * the type of the reference. Two references to a function in another
 * module is more important than 10 references to some constructors?
 * If we do some pattern matching on 20 constructors, is it more
 * important than two functions calls?
 * So Type|Exception > Function|Class|Global >> Constructors|constants ?
 * 
 * notes:
 *  - ml vs mli? just get rid of mli? but one can also want to
 *    care only about mli dependencies, like I did with my 'make doti'. 
 *    We can introduce a Module entity that is the parent of the
 *    ml and mli file (this has-graph unify many things :) ).
 * 
 *    TODO but there is still the issue about where to put the edge
 *    when one module call a function in another module. Do we
 *    link the call to the def in the mli or in the ml?
 * 
 * schema:
 *  Root -> Dir -> Module -> File (.ml) -> # TODO
 * 
 *                        -> File (.mli)
 *       -> Dir -> File  # no intermediate Module node when there is a dupe
 *                       # on a module name (e.g. for main.ml)
 * 
 *       -> Dir -> SubDir -> Module -> ...
 *)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)

(*****************************************************************************)
(* Helpers graph_code *)
(*****************************************************************************)
(* todo: put in graph_code.ml at some point, this is generic code *)

let create_intermediate_directories_if_not_present g dir =
  let dirs = Common.inits_of_relative_dir dir in

  let rec aux current xs =
    match xs with
    | [] -> ()
    | x::xs ->
        let entity = x, E.Dir in
        if G.has_node entity g
        then aux entity xs
        else begin
          g +> G.add_node entity;
          g +> G.add_edge (current, entity) G.Has;
          aux entity xs
        end
  in
  aux G.root dirs


(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)

let parse file =
  Common.save_excursion Flag_parsing_ml.show_parsing_error false (fun ()->
  Common.save_excursion Flag_parsing_ml.exn_when_lexical_error true (fun ()->
    try 
      Parse_ml.parse_program file 
    with Parse_ml.Parse_error _ ->
      (* pr2 ("PARSING problem in: " ^ file); *)
      []
  ))

(* Adjust the set of files: exclude noisy modules (e.g. tests in external/)
 * or modules that would introduce false positive when we do the
 * modulename->file lookup (e.g. applications of external packages)
 *)
let filter_ml_files files =
  files +> Common.exclude (fun file ->
    let (d,b,e) = Common.dbe_of_filename file in
    let xs = Common.split "/" d in
    let ml_file = Common.filename_of_dbe (d,b,"ml") in

    (* pfff specific ... *)
    let is_test_in_external =
      List.mem "external" xs &&
        xs +> List.exists (fun s ->
          match s with
          | "examples" | "tests" |  "test" 
          (* ocamlgraph and ocamlgtk specific *)
          | "dgraph" | "editor" | "view_graph" | "applications"
              -> true
          | _ -> false
        )
    in
    let _is_test =
      xs +> List.exists (fun s ->
        match s with
        | "examples" | "tests" |  "test" -> true
        | _ -> false
      )
    in
    (* pad specific *)
    let is_old = 
      List.mem "old" xs in
    let is_todo = 
      List.mem "todo" xs in
    let is_unparsable_on_purpose =
      List.mem "parsing_errors" xs in

    let is_build_variant = 
      (* mmm *)
      List.mem "safe" xs 
      (* ocaml: arch *)
    in

    let is_generated = 
      List.mem "_build" xs
    in
    let is_garbage =
      b = "myocamlbuild"
    in
    (* some files like in pfff/external/core/ do not have a .ml
     * so at least index the mli. otherwise skip the mli
     *)
    let _is_mli_with_a_ml =
      e = "mli" && Sys.file_exists ml_file
    in

    is_test_in_external || (*is_test || *)
    is_unparsable_on_purpose ||
    (* is_mli_with_a_ml ||  *)
    is_old || is_todo ||
    is_generated || is_garbage ||
    is_build_variant ||
    false
  )

(* todo: move this code in another file? module_analysis_ml.ml ? *)
let lookup_module_name h_module_aliases s =
  try  Hashtbl.find h_module_aliases s
  with Not_found -> s


(*****************************************************************************)
(* Defs *)
(*****************************************************************************)

(* 
 * For now we just create the Dir, File, and Module entities.
 * 
 * TODO: extract Function, Type, Constructor, Field, etc.
 *)
let extract_defs ~g ~duplicate_modules ~ast ~readable ~file =
  let dir = Common.dirname readable in
  create_intermediate_directories_if_not_present g dir;
  let m = Module_ml.module_name_of_filename file in

  g +> G.add_node (readable, E.File);

  match () with
  | _ when List.mem m (Common.keys duplicate_modules) ->
      (* we could attach to two parents when we are almost sure that
       * nobody will reference this module (e.g. because it's an 
       * entry point), but then all the uses in those files would
       * propagate to two parents, so when we have a dupe, we
       * don't create the intermediate Module node. If it's referenced
       * somewhere then it will generate a lookup failure.
       * So just Dir -> File here, no Dir -> Module -> File.
       *)
      g +> G.add_edge ((dir, E.Dir), (readable, E.File)) G.Has;
      (match m with
      | s when s =~ "Main.*" || s =~ "Demo.*" ||
          s =~ "Test.*" || s =~ "Foo.*"
          -> ()
      | _ when file =~ ".*external/" -> ()
      | _ ->
          pr2 (spf "PB: module %s is already present (%s)"
                  m (Common.dump (List.assoc m duplicate_modules)));
      )
  | _ when G.has_node (m, E.Module) g ->
      (match G.parents (m, E.Module) g with
      (* probably because processed .mli or .ml before which created the node *)
      | [p] when p =*= (dir, E.Dir) -> 
          g +> G.add_edge ((m, E.Module), (readable, E.File)) G.Has
      | _ -> raise Impossible
      )
  | _ ->
      (* Dir -> Module -> File *)
      g +> G.add_node (m, E.Module);
      g +> G.add_edge ((dir, E.Dir), (m, E.Module))  G.Has;
      g +> G.add_edge ((m, E.Module), (readable, E.File)) G.Has

(*****************************************************************************)
(* Uses *)
(*****************************************************************************)
let extract_uses ~g ~ast ~readable =
  let src = (readable, E.File) in

  (* when do module A = Foo, A.foo is actually a reference to Foo.foo *)
  let h_module_aliases = Hashtbl.create 101 in

  let add_edge_if_existing_module s =
    let s = lookup_module_name h_module_aliases s in

    let target = (s, E.Module) in
    if G.has_node target g
    then g +> G.add_edge (src, target) G.Use
    else begin
      pr2_once (spf "PB: lookup fail on module %s in %s" 
                   (fst target) readable)
    end
  in
    
  let visitor = V.mk_visitor { V.default_visitor with
    (* todo? does it cover all use cases of modules ? maybe need
     * to introduce a kmodule_name_ref helper in the visitor
     * that does that for us.
     * todo: if want to give more information on edges, need
     * to intercept the module name reference at a upper level
     * like in FunCallSimple. C-s for long_name in ast_ml.ml
     *)
    V.kitem = (fun (k, _) x ->
      (match x with
      | Open (_tok, (qu, (Name (s,_)))) ->
          add_edge_if_existing_module s

      | Module (_, Name (s,_), _, (ModuleName ([], Name (s2,__)))) ->
          Hashtbl.add h_module_aliases s s2;
      | _ -> ()
      );
      k x
    );

    V.kqualifier = (fun (k,_) qu ->
      (match qu with
      | [] -> ()
      | (Name (s, _), _tok)::rest ->
          add_edge_if_existing_module s
      );
      k qu
    );
  } in
  visitor (Program ast);
  ()

(*****************************************************************************)
(* Main entry point *)
(*****************************************************************************)

let build ?(verbose=true) dir =
  let root = Common.realpath dir in
  let all_files = Lib_parsing_ml.find_ml_files_of_dir_or_files [root] in

  (* step0: filter noisy modules/files *)
  let files = filter_ml_files all_files in
  
  (* less: print what was skipped *)

  let g = G.create () in
  g +> G.add_node G.root;

  let duplicate_modules =
    files 
    +> Common.group_by_mapped_key (fun f -> Common.basename f)
    +> List.filter (fun (k, xs) -> List.length xs >= 2)
    +> List.map (fun (k, xs) -> Module_ml.module_name_of_filename k, xs)
  in

  (* step1: creating the nodes and 'Has' edges, the defs *)
  if verbose then pr2 "\nstep1: extract defs";
  files +> Common_extra.progress ~show:verbose (fun k -> 
   List.iter (fun file ->
    k();
    let readable = Common.filename_without_leading_path root file in
    let ast = (* parse file *) () in
    extract_defs ~g ~duplicate_modules ~ast ~readable ~file;
  ));

  (* step2: creating the 'Use' edges, the uses *)
  if verbose then pr2 "\nstep2: extract uses";
  files +> Common_extra.progress ~show:verbose (fun k -> 
   List.iter (fun file ->
     k();
     let readable = Common.filename_without_leading_path root file in
     (* skip files under external/ for now *)
     if readable =~ ".*external/" || readable =~ "web/.*" then ()
     else begin
       let ast = parse file in
       extract_uses ~g ~ast ~readable;
     end
  ));

  g
