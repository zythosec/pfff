(* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_visitor.cmo  pr_o.cmo /tmp/xxx.ml  *)
open Ocaml (* v_string *)
open Ast_go

let v_arithmetic_operator _ = ()
let v_incr_decr _ = ()
let v_prefix_postfix _ = ()


let v_tok v = ()
let v_wrap _of_a (v1, v2) = let v1 = _of_a v1 and v2 = v_tok v2 in ()

let v_ident v = v_wrap v_string v

let v_qualified_ident v = v_list v_ident v

let rec v_type_ =
  function
  | TName v1 -> let v1 = v_qualified_ident v1 in ()
  | TPtr v1 -> let v1 = v_type_ v1 in ()
  | TArray ((v1, v2)) -> let v1 = v_expr v1 and v2 = v_type_ v2 in ()
  | TSlice v1 -> let v1 = v_type_ v1 in ()
  | TArrayEllipsis ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_type_ v2 in ()
  | TFunc v1 -> let v1 = v_func_type v1 in ()
  | TMap ((v1, v2)) -> let v1 = v_type_ v1 and v2 = v_type_ v2 in ()
  | TChan ((v1, v2)) -> let v1 = v_chan_dir v1 and v2 = v_type_ v2 in ()
  | TStruct v1 -> let v1 = v_list v_struct_field v1 in ()
  | TInterface v1 -> let v1 = v_list v_interface_field v1 in ()

and v_chan_dir = function | TSend -> () | TRecv -> () | TBidirectional -> ()
and v_func_type { fparams = v_fparams; fresults = v_fresults } =
  let arg = v_list v_parameter v_fparams in
  let arg = v_list v_parameter v_fresults in ()
and v_parameter { pname = v_pname; ptype = v_ptype; pdots = v_pdots } =
  let arg = v_option v_ident v_pname in
  let arg = v_type_ v_ptype in let arg = v_option v_tok v_pdots in ()
and v_struct_field (v1, v2) =
  let v1 = v_struct_field_kind v1 and v2 = v_option v_tag v2 in ()
and v_struct_field_kind =
  function
  | Field ((v1, v2)) -> let v1 = v_ident v1 and v2 = v_type_ v2 in ()
  | EmbeddedField ((v1, v2)) ->
      let v1 = v_option v_tok v1 and v2 = v_qualified_ident v2 in ()
and v_tag v = v_wrap v_string v
and v_interface_field =
  function
  | Method ((v1, v2)) -> let v1 = v_ident v1 and v2 = v_func_type v2 in ()
  | EmbeddedInterface v1 -> let v1 = v_qualified_ident v1 in ()
and v_expr_or_type v = v_either v_expr v_type_ v
and v_expr =
  function
  | BasicLit v1 -> let v1 = v_literal v1 in ()
  | CompositeLit ((v1, v2)) ->
      let v1 = v_type_ v1 and v2 = v_list v_init v2 in ()
  | Id v1 -> let v1 = v_ident v1 in ()
  | Selector ((v1, v2, v3)) ->
      let v1 = v_expr v1 and v2 = v_tok v2 and v3 = v_ident v3 in ()
  | Index ((v1, v2)) -> let v1 = v_expr v1 and v2 = v_index v2 in ()
  | Slice ((v1, v2)) ->
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
  | Cast ((v1, v2)) -> let v1 = v_type_ v1 and v2 = v_expr v2 in ()
  | Deref ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | Ref ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | Receive ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | Unary ((v1, v2)) ->
      let v1 = v_wrap v_arithmetic_operator v1
      and v2 = v_expr v2
      in ()
  | Binary ((v1, v2, v3)) ->
      let v1 = v_expr v1
      and v2 = v_wrap v_arithmetic_operator v2
      and v3 = v_expr v3
      in ()
  | TypeAssert ((v1, v2)) -> let v1 = v_expr v1 and v2 = v_type_ v2 in ()
  | TypeSwitchExpr ((v1, v2)) -> let v1 = v_expr v1 and v2 = v_tok v2 in ()
  | EllipsisTODO v1 -> let v1 = v_tok v1 in ()
  | FuncLit ((v1, v2)) -> let v1 = v_func_type v1 and v2 = v_stmt v2 in ()
  | ParenType v1 -> let v1 = v_type_ v1 in ()
  | Send ((v1, v2, v3)) ->
      let v1 = v_expr v1 and v2 = v_tok v2 and v3 = v_expr v3 in ()
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
  | ArgDots v1 -> let v1 = v_tok v1 in ()
and v_init =
  function
  | InitExpr v1 -> let v1 = v_expr v1 in ()
  | InitKeyValue ((v1, v2, v3)) ->
      let v1 = v_init v1 and v2 = v_tok v2 and v3 = v_init v3 in ()
  | InitBraces v1 -> let v1 = v_list v_init v1 in ()
and v_constant_expr v = v_expr v
and v_stmt =
  function
  | DeclStmts v1 -> let v1 = v_list v_decl v1 in ()
  | Block v1 -> let v1 = v_list v_stmt v1 in ()
  | Empty -> ()
  | ExprStmt v1 -> let v1 = v_expr v1 in ()
  | Assign ((v1, v2, v3)) ->
      let v1 = v_list v_expr v1
      and v2 = v_tok v2
      and v3 = v_list v_expr v3
      in ()
  | DShortVars ((v1, v2, v3)) ->
      let v1 = v_list v_expr v1
      and v2 = v_tok v2
      and v3 = v_list v_expr v3
      in ()
  | AssignOp ((v1, v2, v3)) ->
      let v1 = v_expr v1
      and v2 = v_wrap v_arithmetic_operator v2
      and v3 = v_expr v3
      in ()
  | IncDec ((v1, v2, v3)) ->
      let v1 = v_expr v1
      and v2 = v_wrap v_incr_decr v2
      and v3 = v_prefix_postfix v3
      in ()
  | If ((v1, v2, v3, v4)) ->
      let v1 = v_option v_stmt v1
      and v2 = v_expr v2
      and v3 = v_stmt v3
      and v4 = v_option v_stmt v4
      in ()
  | Switch ((v1, v2, v3)) ->
      let v1 = v_option v_stmt v1
      and v2 = v_option v_stmt v2
      and v3 = v_list v_case_clause v3
      in ()
  | Select ((v1, v2)) ->
      let v1 = v_tok v1 and v2 = v_list v_comm_clause v2 in ()
  | For ((v1, v2)) ->
      let v1 =
        (match v1 with
         | (v1, v2, v3) ->
             let v1 = v_option v_stmt v1
             and v2 = v_option v_expr v2
             and v3 = v_option v_stmt v3
             in ())
      and v2 = v_stmt v2
      in ()
  | Range ((v1, v2, v3, v4)) ->
      let v1 =
        v_option
          (fun (v1, v2) -> let v1 = v_list v_expr v1 and v2 = v_tok v2 in ())
          v1
      and v2 = v_tok v2
      and v3 = v_expr v3
      and v4 = v_stmt v4
      in ()
  | Return ((v1, v2)) ->
      let v1 = v_tok v1 and v2 = v_option (v_list v_expr) v2 in ()
  | Break ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_option v_ident v2 in ()
  | Continue ((v1, v2)) ->
      let v1 = v_tok v1 and v2 = v_option v_ident v2 in ()
  | Goto ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_ident v2 in ()
  | Fallthrough v1 -> let v1 = v_tok v1 in ()
  | Label ((v1, v2)) -> let v1 = v_ident v1 and v2 = v_stmt v2 in ()
  | Go ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_call_expr v2 in ()
  | Defer ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_call_expr v2 in ()
and v_case_clause (v1, v2) = let v1 = v_case_kind v1 and v2 = v_stmt v2 in ()
and v_case_kind =
  function
  | CaseExprs v1 -> let v1 = v_list v_expr_or_type v1 in ()
  | CaseAssign ((v1, v2, v3)) ->
      let v1 = v_list v_expr_or_type v1
      and v2 = v_tok v2
      and v3 = v_expr v3
      in ()
  | CaseDefault v1 -> let v1 = v_tok v1 in ()
and v_comm_clause v = v_case_clause v
and v_call_expr (v1, v2) = let v1 = v_expr v1 and v2 = v_arguments v2 in ()
and v_decl =
  function
  | DConst ((v1, v2, v3)) ->
      let v1 = v_ident v1
      and v2 = v_option v_type_ v2
      and v3 = v_option v_constant_expr v3
      in ()
  | DVar ((v1, v2, v3)) ->
      let v1 = v_ident v1
      and v2 = v_option v_type_ v2
      and v3 = v_option v_expr v3
      in ()
  | DTypeAlias ((v1, v2, v3)) ->
      let v1 = v_ident v1 and v2 = v_tok v2 and v3 = v_type_ v3 in ()
  | DTypeDef ((v1, v2)) -> let v1 = v_ident v1 and v2 = v_type_ v2 in ()
  
and v_import_kind =
  function
  | ImportOrig -> ()
  | ImportNamed v1 -> let v1 = v_ident v1 in ()
  | ImportDot v1 -> let v1 = v_tok v1 in ()
  
