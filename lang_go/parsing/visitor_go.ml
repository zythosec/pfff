(* Yoann Padioleau
 *
 * Copyright (C) 2020 r2c
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
open OCaml (* v_string *)
open Ast_go

(* Disable warnings against unused variables *)
[@@@warning "-26"]

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)

(* hooks *)

type visitor_in = {
  kident:   (ident       -> unit) * visitor_out -> ident       -> unit;
  kexpr:    (expr        -> unit) * visitor_out -> expr        -> unit;
  kstmt:    (stmt        -> unit) * visitor_out -> stmt        -> unit;
  ktype:    (type_         -> unit) * visitor_out -> type_         -> unit;
  kdecl:    (decl        -> unit) * visitor_out -> decl        -> unit;
  ktop_decl:    (top_decl        -> unit) * visitor_out -> top_decl   -> unit;
  kfunction: (function_ -> unit) * visitor_out -> function_ -> unit;
  kparameter: (parameter -> unit) * visitor_out -> parameter -> unit;
  kinit: (init -> unit) * visitor_out -> init -> unit;
  kprogram: (program     -> unit) * visitor_out -> program     -> unit;

  kinfo: (tok -> unit) * visitor_out -> tok -> unit;
}

and visitor_out = any -> unit


let default_visitor = {
  kident   = (fun (k,_) x -> k x);
  kexpr    = (fun (k,_) x -> k x);
  kstmt    = (fun (k,_) x -> k x);
  ktype    = (fun (k,_) x -> k x);
  kdecl    = (fun (k,_) x -> k x);
  ktop_decl    = (fun (k,_) x -> k x);
  kfunction =   (fun (k,_) x -> k x);
  kprogram = (fun (k,_) x -> k x);
  kparameter = (fun (k,_) x -> k x);
  kinit = (fun (k,_) x -> k x);
  kinfo = (fun (k,_) x -> k x);
}


let v_arithmetic_operator _ = ()
let v_incr_decr _ = ()
let v_prefix_postfix _ = ()

let (mk_visitor: visitor_in -> visitor_out) = fun vin ->

  (* start of auto generation *)

  (* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_visitor.cmo  pr_o.cmo /tmp/xxx.ml  *)


  let rec v_wrap: 'a. ('a -> unit) -> 'a wrap -> unit = fun _of_a (v1, v2) ->
    let v1 = _of_a v1 and v2 = v_info v2 in ()

  and v_bracket: 'a. ('a -> unit) -> 'a bracket -> unit =
    fun of_a (v1, v2, v3) ->
      let v1 = v_info v1 and v2 = of_a v2 and v3 = v_info v3 in ()

  and v_info x =
    let k _x = () in
    vin.kinfo (k, all_functions) x

  and v_tok v = v_info v

  and v_ident x =
    let k v =
      v_wrap v_string v
    in
    vin.kident (k, all_functions) x

  and v_qualified_ident v = v_list v_ident v

  and v_type_ x =
    let k =
      function
      | TName v1 -> let v1 = v_qualified_ident v1 in ()
      | TPtr (t, v1) ->
          let t = v_tok t in
          let v1 = v_type_ v1 in ()
      | TArray (v1, v2) -> let v1 = v_bracket (v_option v_expr) v1
          and v2 = v_type_ v2 in ()
      | TArrayEllipsis (v1, v2) ->
          let v1 = v_bracket v_tok v1 and v2 = v_type_ v2 in ()
      | TFunc v1 -> let v1 = v_func_type v1 in ()
      | TMap (t, v1, v2) ->
          let t = v_tok t in
          let v1 = v_bracket v_type_ v1 and v2 = v_type_ v2 in ()
      | TChan (t, v1, v2) ->
          let t = v_tok t in
          let v1 = v_chan_dir v1 and v2 = v_type_ v2 in ()
      | TStruct (t, v1) ->
          let t = v_tok t in
          let v1 = v_bracket (v_list v_struct_field) v1 in ()
      | TInterface (t, v1) ->
          let t = v_tok t in
          let v1 = v_bracket (v_list v_interface_field) v1 in ()
    in
    vin.ktype (k, all_functions) x

  and v_chan_dir = function | TSend -> () | TRecv -> () | TBidirectional -> ()
  and v_func_type { fparams = v_fparams; fresults = v_fresults } =
    let arg = v_list v_parameter_binding v_fparams in
    let arg = v_list v_parameter_binding v_fresults in ()

  and v_parameter_binding =
    function
    | ParamClassic v1 -> let v1 = v_parameter v1 in ()
    | ParamEllipsis v1 -> let v1 = v_tok v1 in ()

  and v_parameter x =
    let k { pname = v_pname; ptype = v_ptype; pdots = v_pdots } =
      let arg = v_option v_ident v_pname in
      let arg = v_type_ v_ptype in let arg = v_option v_tok v_pdots in ()
    in
    vin.kparameter (k, all_functions) x
  and v_struct_field (v1, v2) =
    let v1 = v_struct_field_kind v1 and v2 = v_option v_tag v2 in ()
  and v_struct_field_kind =
    function
    | Field (v1, v2) -> let v1 = v_ident v1 and v2 = v_type_ v2 in ()
    | EmbeddedField (v1, v2) ->
        let v1 = v_option v_tok v1 and v2 = v_qualified_ident v2 in ()
    | FieldEllipsis t -> v_tok t
  and v_tag v = v_wrap v_string v
  and v_interface_field =
    function
    | Method (v1, v2) -> let v1 = v_ident v1 and v2 = v_func_type v2 in ()
    | EmbeddedInterface v1 -> let v1 = v_qualified_ident v1 in ()
    | FieldEllipsis2 t -> v_tok t
  and v_expr_or_type v = v_either v_expr v_type_ v

  and v_expr x =
    let k =
      function
      | DeepEllipsis v1 -> v_bracket v_expr v1
      | BasicLit v1 -> let v1 = v_literal v1 in ()
      | CompositeLit (v1, v2) ->
          let v1 = v_type_ v1 and v2 = v_bracket (v_list v_init) v2 in ()
      | Id (v1) -> let v1 = v_ident v1 in ()
      | Selector (v1, v2, v3) ->
          let v1 = v_expr v1 and v2 = v_tok v2 and v3 = v_ident v3 in ()
      | Index (v1, v2) -> let v1 = v_expr v1 and v2 = v_bracket v_index v2 in ()
      | Slice (v1, v2) ->
          let v1 = v_expr v1
          and v2 =
            (match v2 with
             | (v1, v2, v3) ->
                 let v1 = v_option v_expr v1
                 and v2 = v_option v_expr v2
                 and v3 = v_option v_expr v3
                 in ())
          in ()
      | Call v1 -> let v1 = v_call_expr v1 in ()
      | Cast (v1, v2) -> let v1 = v_type_ v1 and v2 = v_expr v2 in ()
      | Deref (v1, v2) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
      | Ref (v1, v2) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
      | Receive (v1, v2) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
      | Unary (v1, v2) ->
          let v1 = v_wrap v_arithmetic_operator v1
          and v2 = v_expr v2
          in ()
      | Binary (v1, v2, v3) ->
          let v1 = v_expr v1
          and v2 = v_wrap v_arithmetic_operator v2
          and v3 = v_expr v3
          in ()
      | TypeAssert (v1, v2) -> let v1 = v_expr v1 and v2 = v_type_ v2 in ()
      | TypeSwitchExpr (v1, v2) -> let v1 = v_expr v1 and v2 = v_tok v2 in ()
      | Ellipsis v1 -> let v1 = v_tok v1 in ()
      | TypedMetavar (v1, v2, v3) ->
          let v1 = v_ident v1 in
          let v2 = v_tok v2 in
          let v3 = v_type_ v3 in
          ()
      | FuncLit x -> v_function_ x
      | ParenType v1 -> let v1 = v_type_ v1 in ()
      | Send (v1, v2, v3) ->
          let v1 = v_expr v1 and v2 = v_tok v2 and v3 = v_expr v3 in ()
    in
    vin.kexpr (k, all_functions) x

  and v_literal =
    function
    | Int v1 -> let v1 = v_wrap v_string v1 in ()
    | Float v1 -> let v1 = v_wrap v_string v1 in ()
    | Imag v1 -> let v1 = v_wrap v_string v1 in ()
    | Rune v1 -> let v1 = v_wrap v_string v1 in ()
    | String v1 -> let v1 = v_wrap v_string v1 in ()
  and v_index v = v_expr v
  and v_arguments v = v_list v_argument v
  and v_argument =
    function
    | Arg v1 -> let v1 = v_expr v1 in ()
    | ArgType v1 -> let v1 = v_type_ v1 in ()
    | ArgDots (v1, v2) -> let v1 = v_expr v1 in let v2 = v_tok v2 in ()
  and v_init x =
    let k =
      function
      | InitExpr v1 -> let v1 = v_expr v1 in ()
      | InitKeyValue (v1, v2, v3) ->
          let v1 = v_init v1 and v2 = v_tok v2 and v3 = v_init v3 in ()
      | InitBraces v1 -> let v1 = v_bracket (v_list v_init) v1 in ()
    in
    vin.kinit (k, all_functions) x
  and v_constant_expr v = v_expr v

  and v_stmt x =
    let k =
      function
      | DeclStmts v1 -> let v1 = v_list v_decl v1 in ()
      | Block v1 -> let v1 = v_bracket (v_list v_stmt) v1 in ()
      | Empty -> ()
      | SimpleStmt v1 -> v_simple v1

      | If (t, v1, v2, v3, v4) ->
          let t = v_tok t in
          let v1 = v_option v_simple v1
          and v2 = v_expr v2
          and v3 = v_stmt v3
          and v4 = v_option v_stmt v4
          in ()
      | Switch (v0, v1, v2, v3) ->
          let v0 = v_tok v0 in
          let v1 = v_option v_simple v1
          and v2 = v_option v_simple v2
          and v3 = v_list v_case_clause v3
          in ()
      | Select (v1, v2) ->
          let v1 = v_tok v1 and v2 = v_list v_comm_clause v2 in ()
      | For (t, v1, v2) ->
          let t = v_tok t in
          let v1 =
            (match v1 with
             | (v1, v2, v3) ->
                 let v1 = v_option v_simple v1
                 and v2 = v_option v_expr v2
                 and v3 = v_option v_simple v3
                 in ())
          and v2 = v_stmt v2
          in ()
      | Range (t, v1, v2, v3, v4) ->
          let t = v_tok t in
          let v1 =
            v_option
              (fun (v1, v2) -> let v1 = v_list v_expr v1 and v2 = v_tok v2 in ())
              v1
          and v2 = v_tok v2
          and v3 = v_expr v3
          and v4 = v_stmt v4
          in ()
      | Return (v1, v2) ->
          let v1 = v_tok v1 and v2 = v_option (v_list v_expr) v2 in ()
      | Break (v1, v2) -> let v1 = v_tok v1 and v2 = v_option v_ident v2 in ()
      | Continue (v1, v2) ->
          let v1 = v_tok v1 and v2 = v_option v_ident v2 in ()
      | Goto (v1, v2) -> let v1 = v_tok v1 and v2 = v_ident v2 in ()
      | Fallthrough v1 -> let v1 = v_tok v1 in ()
      | Label (v1, v2) -> let v1 = v_ident v1 and v2 = v_stmt v2 in ()
      | Go (v1, v2) -> let v1 = v_tok v1 and v2 = v_call_expr v2 in ()
      | Defer (v1, v2) -> let v1 = v_tok v1 and v2 = v_call_expr v2 in ()
    in
    vin.kstmt (k, all_functions) x

  and v_simple = function
    | ExprStmt v1 -> let v1 = v_expr v1 in ()
    | Assign (v1, v2, v3) ->
        let v1 = v_list v_expr v1
        and v2 = v_tok v2
        and v3 = v_list v_expr v3
        in ()
    | DShortVars (v1, v2, v3) ->
        let v1 = v_list v_expr v1
        and v2 = v_tok v2
        and v3 = v_list v_expr v3
        in ()
    | AssignOp (v1, v2, v3) ->
        let v1 = v_expr v1
        and v2 = v_wrap v_arithmetic_operator v2
        and v3 = v_expr v3
        in ()
    | IncDec (v1, v2, v3) ->
        let v1 = v_expr v1
        and v2 = v_wrap v_incr_decr v2
        and v3 = v_prefix_postfix v3
        in ()

  and v_case_clause = function
    | CaseClause (v1, v2) -> let v1 = v_case_kind v1 and v2 = v_stmt v2 in ()
    | CaseEllipsis (v1, v2) -> v_tok v1; v_tok v2

  and v_case_kind =
    function
    | CaseExprs (t, v1) ->
        let t = v_tok t in
        let v1 = v_list v_expr_or_type v1 in ()
    | CaseAssign (t, v1, v2, v3) ->
        let t = v_tok t in
        let v1 = v_list v_expr_or_type v1
        and v2 = v_tok v2
        and v3 = v_expr v3
        in ()
    | CaseDefault v1 -> let v1 = v_tok v1 in ()

  and v_comm_clause v = v_case_clause v
  and v_call_expr (v1, v2) =
    let v1 = v_expr v1
    and v2 = v_bracket v_arguments v2 in
    ()

  and v_decl x =
    let k =
      function
      | DConst (v1, v2, v3) ->
          let v1 = v_ident v1
          and v2 = v_option v_type_ v2
          and v3 = v_option v_constant_expr v3
          in ()
      | DVar (v1, v2, v3) ->
          let v1 = v_ident v1
          and v2 = v_option v_type_ v2
          and v3 = v_option v_expr v3
          in ()
      | DTypeAlias (v1, v2, v3) ->
          let v1 = v_ident v1 and v2 = v_tok v2 and v3 = v_type_ v3 in ()
      | DTypeDef (v1, v2) -> let v1 = v_ident v1 and v2 = v_type_ v2 in ()
    in
    vin.kdecl (k, all_functions) x

  and v_function_ x =
    let k (v1, v2) =
      let v1 = v_func_type v1 and v2 = v_stmt v2 in ()
    in
    vin.kfunction (k, all_functions) x

  and v_top_decl x =
    let k = function
      | DFunc (t, v1, v2) ->
          v_tok t;
          let v1 = v_ident v1 and v2 = v_function_ v2 in ()
      | DMethod (t, v1, v2, v3) ->
          v_tok t;
          let v1 = v_ident v1
          and v2 = v_parameter v2
          and v3 = v_function_ v3
          in ()
      | DTop v1 -> let v1 = v_decl v1 in ()
      | STop v1 -> let v1 = v_stmt v1 in ()
      | Package (v1, v2) -> v_package (v1, v2)
      | Import x -> v_import x
    in
    vin.ktop_decl (k, all_functions) x

  and v_import { i_path = v_i_path; i_kind = v_i_kind; i_tok = t } =
    let arg = v_tok t in
    let arg = v_wrap v_string v_i_path in
    let arg = v_import_kind v_i_kind in ()

  and v_import_kind =
    function
    | ImportOrig -> ()
    | ImportNamed v1 -> let v1 = v_ident v1 in ()
    | ImportDot v1 -> let v1 = v_tok v1 in ()

  and v_package (v1, v2) =
    let v1 = v_tok v1 in
    let v2 = v_ident v2 in
    ()
  and v_program x =
    let k x = v_list v_top_decl x in
    vin.kprogram (k, all_functions) x

  and v_item = function
    | ITop v1 -> v_top_decl v1
    | IImport v1 -> v_import v1
    | IStmt v1 -> v_stmt v1

  and v_partial = function
    | PartialDecl v1 -> v_top_decl v1

  and v_any =
    function
    | Partial v1 -> v_partial v1
    | E v1 -> let v1 = v_expr v1 in ()
    | S v1 -> let v1 = v_stmt v1 in ()
    | T v1 -> let v1 = v_type_ v1 in ()
    | Decl v1 -> let v1 = v_decl v1 in ()
    | I v1 -> let v1 = v_import v1 in ()
    | P v1 -> let v1 = v_program v1 in ()
    | Ident v1 -> let v1 = v_ident v1 in ()
    | Ss v1 -> let v1 = v_list v_stmt v1 in ()
    | Item v1 -> let v1 = v_item v1 in ()
    | Items v1 -> let v1 = v_list v_item v1 in ()

  and all_functions x = v_any x
  in
  all_functions
