(* Yoann Padioleau
 *
 * Copyright (C) 2019 r2c
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
open OCaml
open Ast_js

(* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_visitor.cmo  pr_o.cmo /tmp/xxx.ml  *)

(* Disable warnings against unused variables *)
[@@@warning "-26"]

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(* hooks *)
type visitor_in = {
  kexpr: (expr  -> unit) * visitor_out -> expr  -> unit;
  kstmt: (stmt  -> unit) * visitor_out -> stmt  -> unit;
  ktop: (toplevel -> unit) * visitor_out -> toplevel -> unit;
  kprop: (property  -> unit) * visitor_out -> property  -> unit;
  kparam: (parameter_classic  -> unit) * visitor_out -> parameter_classic  -> unit;
  kinfo: (tok -> unit)  * visitor_out -> tok  -> unit;
}
and visitor_out = any -> unit

let default_visitor =
  { kexpr   = (fun (k,_) x -> k x);
    kstmt   = (fun (k,_) x -> k x);
    ktop   = (fun (k,_) x -> k x);
    kprop   = (fun (k,_) x -> k x);
    kparam   = (fun (k,_) x -> k x);
    kinfo = (fun (k,_) x -> k x);
  }

let (mk_visitor: visitor_in -> visitor_out) = fun vin ->

let rec v_info x =
  let k x = match x with { Parse_info.
     token = _v_pinfox; transfo = _v_transfo
    } ->
(*
    let arg = Parse_info.v_pinfo v_pinfox in
    let arg = v_unit v_comments in
    let arg = Parse_info.v_transformation v_transfo in
*)
    ()
  in
  vin.kinfo (k, all_functions) x

(* start of auto generation *)

and v_tok v = v_info v

and v_wrap: 'a. ('a -> unit) -> 'a wrap -> unit = fun of_a (v1, v2) ->
  let v1 = of_a v1 and v2 = v_info v2 in ()

and v_bracket: 'a. ('a -> unit) -> 'a bracket -> unit = 
  fun of_a (v1, v2, v3) ->
  let v1 = v_info v1 and v2 = of_a v2 and v3 = v_info v3 in ()

and v_name v = v_wrap v_string v
and v_ident x = v_name x

and v_filename v = v_wrap v_string v

and v_special =
  function
  | UseStrict -> ()
  | Null -> ()
  | Undefined -> ()
  | This -> ()
  | Super -> ()
  | Require -> ()
  | Exports -> ()
  | Module -> ()
  | Define -> ()
  | Arguments -> ()
  | New -> ()
  | NewTarget -> ()
  | Eval -> ()
  | Seq -> ()
  | Typeof -> ()
  | Instanceof -> ()
  | In -> ()
  | Delete -> ()
  | Void -> ()
  | Spread -> ()
  | Yield -> ()
  | YieldStar -> ()
  | Await -> ()
  | Encaps v1 -> let v1 = v_bool v1 in ()
  | ArithOp v -> let v = v_arith_op v in ()
  | IncrDecr v -> let v = v_inc_dec v in ()

and v_inc_dec _ = ()
and v_arith_op _ = ()

and v_property_name =
  function
  | PN v1 -> let v1 = v_name v1 in ()
  | PN_Computed v1 -> let v1 = v_expr v1 in ()    

and v_label v = v_wrap v_string v

and v_xml_attribute v = 
  match v with
  | XmlAttr (v1, v2) -> let v1 = v_ident v1 and v2 = v_xml_attr v2 in ()
  | XmlAttrExpr v -> v_bracket v_expr v
  | XmlEllipsis v -> v_tok v

and
  v_xml { xml_tag = v_xml_tag; xml_attrs = v_xml_attrs; xml_body = vv_xml_body
        } =
  let v_xml_tag = v_ident v_xml_tag in
  let v_xml_attrs = v_list v_xml_attribute  v_xml_attrs in
  let vv_xml_body = v_list v_xml_body vv_xml_body in 
  ()
and v_xml_attr v = v_expr v
and v_xml_body =
  function
  | XmlText v1 -> let v1 = v_wrap v_string v1 in ()
  | XmlExpr v1 -> let v1 = v_expr v1 in ()
  | XmlXml v1 -> let v1 = v_xml v1 in ()

and v_todo_category v1 = v_wrap v_string v1

and v_expr (x: expr) =
  (* tweak *)
  let k x =  match x with
  | Cast (v1, v2, v3) -> 
        v_expr v1; v_tok v2; v_type_ v3
  | TypeAssert (v1, v2, v3) -> 
        v_expr v1; v_tok v2; v_type_ v3
  | ExprTodo (v1, v2) -> v_todo_category v1; v_list v_expr v2
  | Xml v1 -> let v1 = v_xml v1 in ()
  | Bool v1 -> let v1 = v_wrap v_bool v1 in ()
  | Num v1 -> let v1 = v_wrap v_string v1 in ()
  | String v1 -> let v1 = v_wrap v_string v1 in ()
  | Regexp v1 -> let v1 = v_wrap v_string v1 in ()
  | Id (v1) -> let v1 = v_name v1 in ()
  | IdSpecial v1 -> let v1 = v_wrap v_special v1 in ()
  | Assign ((v1, v2, v3)) -> 
        let v1 = v_expr v1 and v2 = v_tok v2 and v3 = v_expr v3 in ()
  | ArrAccess ((v1, v2)) -> let v1 = v_expr v1 and v2 = v_bracket v_expr v2 in ()
  | Obj v1 -> let v1 = v_obj_ v1 in ()
  | Ellipsis v1 -> let v1 = v_tok v1 in ()
  | DeepEllipsis v1 -> let v1 = v_bracket v_expr v1 in ()
  | Class (v1, v2) -> let v1 = v_class_definition v1 in let v2 = v_option v_name v2 in ()
  | ObjAccess ((v1, t, v2)) ->
      let v1 = v_expr v1 and v2 = v_property_name v2 in
      let t = v_tok t in
      ()
  | Fun ((v1, v2)) -> let v1 = v_function_definition v1 and v2 = v_option v_name v2 in ()
  | Apply ((v1, v2)) -> let v1 = v_expr v1 and v2 = v_bracket (v_list v_expr) v2 in ()
  | Arr ((v1)) -> let v1 = v_bracket (v_list v_expr) v1 in ()
  | Conditional ((v1, v2, v3)) ->
      let v1 = v_expr v1 and v2 = v_expr v2 and v3 = v_expr v3 in ()
  in  
  vin.kexpr (k, all_functions) x


and v_stmt x =
  let k x = match x with
  | StmtTodo (v1, v2) -> v_todo_category v1; v_list v_any v2
  | M v1 -> let v1 = v_module_directive v1 in ()
  | DefStmt v1 -> let v1 = v_def v1 in ()
  | Block v1 -> let v1 = v_bracket (v_list v_stmt) v1 in ()
  | ExprStmt (v1, t) -> let v1 = v_expr v1 in let t= v_tok t in ()
  | If ((t, v1, v2, v3)) ->
      let t = v_tok t in
      let v1 = v_expr v1 and v2 = v_stmt v2 and v3 = v_option v_stmt v3 in ()
  | Do ((t, v1, v2)) -> 
      let t = v_tok t in
      let v1 = v_stmt v1 and v2 = v_expr v2 in ()
  | While ((t, v1, v2)) -> 
      let t = v_tok t in
      let v1 = v_expr v1 and v2 = v_stmt v2 in ()
  | For ((t, v1, v2)) -> 
      let t = v_tok t in
      let v1 = v_for_header v1 and v2 = v_stmt v2 in ()
  | Switch ((v0, v1, v2)) -> 
        let v0 = v_tok v0 in
        let v1 = v_expr v1 and v2 = v_list v_case v2 in ()
  | Continue (t, v1) -> 
      let t = v_tok t in
      let v1 = v_option v_label v1 in ()
  | Break (t, v1) -> 
      let t = v_tok t in
      let v1 = v_option v_label v1 in ()
  | Return (t, v1) -> 
      let t = v_tok t in
      let v1 = v_option v_expr v1 in ()
  | Label ((v1, v2)) -> let v1 = v_label v1 and v2 = v_stmt v2 in ()
  | Throw (t, v1) -> 
      let t = v_tok t in
      let v1 = v_expr v1 in ()
  | Try ((t, v1, v2, v3)) ->
      let t = v_tok t in
      let v1 = v_stmt v1
      and v2 = v_option v_catch_block v2
      and v3 = v_option v_tok_and_stmt v3
      in ()
  | With (v1, v2, v3) ->
        v_tok v1;
        v_expr v2;
        v_stmt v3
  in
  vin.kstmt (k, all_functions) x

and v_catch_block = function
  | BoundCatch (t, v1, v2) ->
      let t = v_tok t
      and v1 = v_expr v1
      and v2 = v_stmt v2
      in ()
  | UnboundCatch (t, v1) ->
      let t = v_tok t
      and v1 = v_stmt v1
      in ()

and v_tok_and_stmt (t, v) = 
  let t = v_tok t in
  let v = v_stmt v in
  ()
and v_for_header =
  function
  | ForEllipsis v1 -> v_tok v1
  | ForClassic ((v1, v2, v3)) ->
      let v1 = v_either (v_list v_var) v_expr v1
      and v2 = v_option v_expr v2
      and v3 = v_option v_expr v3
      in ()
  | ForIn ((v1, t, v2)) | ForOf ((v1, t, v2)) ->
      let t = v_tok t in
      let v1 = v_either v_var v_expr v1 and v2 = v_expr v2 in ()

and v_case =
  function
  | Case ((t, v1, v2)) -> 
      let t = v_tok t in
      let v1 = v_expr v1 and v2 = v_stmt v2 in ()
  | Default (t, v1) -> 
      let t = v_tok t in
      let v1 = v_stmt v1 in ()

and v_resolved_name _ = ()

and v_def (ent, defkind) =
  v_entity ent;
  v_definition_kind defkind

and v_entity { name; } =
  v_ident name

and v_definition_kind = function
  | FuncDef def -> v_function_definition def
  | ClassDef def -> v_class_definition def
  | VarDef def -> v_variable_definition def
  | DefTodo (v1, v2) -> v_todo_category v1; v_list v_any v2


and v_var (ent, def) = 
  v_entity ent;
  v_variable_definition def


and v_variable_definition { v_kind=v_v_kind; v_init = v_v_init; v_type=vt} =
  let arg = v_wrap v_var_kind v_v_kind in 
  let arg = v_option v_expr v_v_init in 
  v_option v_type_ vt;
  ()
and v_var_kind = function | Var -> () | Let -> () | Const -> ()

and v_function_definition { f_attrs = v_f_props; f_params = v_f_params; 
             f_body = v_f_body; f_rettype } =
  let arg = v_list v_attribute v_f_props in
  let arg = v_list v_parameter_binding v_f_params in 
  let arg = v_stmt v_f_body in
  v_option v_type_ f_rettype;
  ()

and v_parameter_binding =
  function
  | ParamClassic v1 -> let v1 = v_parameter v1 in ()
  | ParamPattern v1 -> v_pattern v1
  | ParamEllipsis v1 -> let v1 = v_tok v1 in ()

and v_pattern x = v_expr x

and v_parameter x =
 let k x = 
 match x with
   { p_name = v_p_name; p_default = v_p_default; p_dots = v_p_dots; 
     p_type; p_attrs } ->
    let arg = v_name v_p_name in
    let arg = v_option v_expr v_p_default in 
    let arg = v_option v_tok v_p_dots in
    v_option v_type_ p_type;
    v_list v_attribute p_attrs;
    ()
  in
  vin.kparam (k, all_functions) x

and v_dotted_ident xs = v_list v_ident xs

and v_argument x = v_expr x

and v_attribute = function
  | KeywordAttr x -> v_keyword_attribute x
  | NamedAttr (v1, v2, v3) ->
      v_tok v1 ;
      v_dotted_ident v2;
      v_option (v_bracket (v_list v_argument)) v3
      
and v_fun_prop x = v_keyword_attribute x
and v_keyword_attribute _ = ()
and v_class_kind _ = ()
and v_parent = function
 | Common.Left e -> v_expr e
 | Common.Right t -> v_type_ t

and v_obj_ v = v_bracket (v_list v_property) v
and v_class_definition { c_extends = v_c_extends; c_body = v_c_body; 
               c_kind; c_attrs; c_implements } =
  let arg = v_wrap v_class_kind c_kind in
  let arg = v_list v_parent v_c_extends in
  let arg = v_bracket (v_list v_property) v_c_body in 
  let arg = v_list v_attribute c_attrs in
  v_list v_type_ c_implements;
  ()

(* TODO? call Visitor_AST with local kinfo? meh *)
and v_type_ _x = ()
  
and v_property x =
  (* tweak *)
  let k x =  match x with
  | FieldTodo (v1, v2) -> v_todo_category v1; v_stmt v2
  | Field { fld_name; fld_attrs; fld_type; fld_body} ->
      let v1 = v_property_name fld_name
      and v2 = v_list v_attribute fld_attrs
      and ty = v_option v_type_ fld_type
      and v3 = v_option v_expr fld_body
      in ()
  | FieldSpread (t, v1) -> let t = v_tok t in let v1 = v_expr v1 in ()
  | FieldEllipsis v1 -> let v1 = v_tok v1 in ()
  | FieldPatDefault (v1, v2, v3) ->
        v_pattern v1;
        v_tok v2;
        v_expr v3
  in
  vin.kprop (k, all_functions) x

and v_property_prop _ = ()

  
and v_toplevel x =
  let k x =
    v_stmt x
  in
  vin.ktop (k, all_functions) x

and v_module_directive x = 
  match x with
  | ReExportNamespace (v1, v2, v3, v4) ->
      v_tok v1; v_tok v2; v_tok v3; v_filename v4
  | Import ((t, v1, v2, v3)) ->
      let t = v_tok t in
      let v1 = v_name v1 and v2 = v_option v_name v2 and v3 = v_filename v3 in ()
  | ImportFile ((t, v1)) ->
      let t = v_tok t in
      let v1 = v_name v1 in ()
  | ModuleAlias ((t, v1, v2)) ->
      let t = v_tok t in
      let v1 = v_name v1 and v2 = v_filename v2 in ()
  | Export ((t, v1)) -> 
      let t = v_tok t in
      let v1 = v_name v1 in ()

and v_any =
  function
  | Expr v1 -> let v1 = v_expr v1 in ()
  | Stmt v1 -> let v1 = v_stmt v1 in ()
  | Stmts v1 -> let v1 = v_list v_stmt v1 in ()
  | Pattern v1 -> v_pattern v1
  | Type v1 -> v_type_ v1
  | Program v1 -> let v1 = v_program v1 in ()

and v_program v = v_list v_toplevel v

and all_functions x = v_any x
in
all_functions

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)

let do_visit_with_ref mk_hooks = fun any ->
  let res = ref [] in
  let hooks = mk_hooks res in
  let vout = mk_visitor hooks in
  vout any;
  List.rev !res
