(* Yoann Padioleau
 * 
 * Copyright (C) 2009-2010 Facebook
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
(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(* 
 * It would be more convenient to move this file elsewhere like in analyse_xxx/
 * but we want our AST to contain scope annotations so it's convenient to 
 * have the type definition of scope there.
 *)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)

(* todo? could use polymorphic variant for that ? the scoping will
 * be differerent for each language but they will also have stuff
 * in common which may be a good spot for polymorphic variant.
 *)
type scope = 
  | Global
  | Local 
  | Param
  | Static

  | Class

  | LocalExn
  | LocalIterator

  (* php specific? *)
  | ListBinded
  (* | Class ? *)

  | Closed

  | NoScope

(*****************************************************************************)
(* String-of *)
(*****************************************************************************)

let string_of_scope = function
  | Global ->  "Global"
  | Local ->  "Local"
  | Param ->  "Param"
  | Static ->  "Static"
  | Class ->  "Class"
  | LocalExn ->  "LocalExn"
  | LocalIterator ->  "LocalIterator"
  | ListBinded ->  "ListBinded"
  | Closed ->  "Closed"
  | NoScope ->  "NoScope"

(*****************************************************************************)
(* Meta *)
(*****************************************************************************)

let vof_scope x = 
  match x with
  | Global -> Ocaml.VSum (("Global", []))
  | Local -> Ocaml.VSum (("Local", []))
  | Param -> Ocaml.VSum (("Param", []))
  | Static -> Ocaml.VSum (("Static", []))
  | Class -> Ocaml.VSum (("Class", []))
  | LocalExn -> Ocaml.VSum (("LocalExn", []))
  | LocalIterator -> Ocaml.VSum (("LocalIterator", []))
  | ListBinded -> Ocaml.VSum (("ListBinded", []))
  | Closed -> Ocaml.VSum (("Closed", []))
  | NoScope -> Ocaml.VSum (("NoScope", []))

let map_scope =
  function
  | Global -> Global
  | Local -> Local
  | Param -> Param
  | Static -> Static
  | NoScope -> NoScope
  | ListBinded -> ListBinded
  | LocalIterator -> LocalIterator
  | LocalExn -> LocalExn
  | Closed -> Closed
  | Class -> Class

(* still needed ? *)
let sexp_of_scope x =
  match x with
  | Global -> Sexp.Atom "Global"
  | Local -> Sexp.Atom "Local"
  | Param -> Sexp.Atom "Param"
  | Static -> Sexp.Atom "Static"
  | NoScope -> Sexp.Atom "NoScope"
  | ListBinded -> Sexp.Atom "ListBinded"
  | LocalIterator -> Sexp.Atom "LocalIterator"
  | LocalExn -> Sexp.Atom "LocalExn"
  | Closed -> Sexp.Atom "Closed"
  | Class -> Sexp.Atom "Class"
