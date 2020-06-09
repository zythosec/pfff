(* Mike Furr
 *
 * Copyright (C) 2010 Mike Furr
 * Copyright (C) 2020 r2c
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *)

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* Abstract Syntax Tree for Ruby 1.9
 *
 * Most of the code in this file derives from code from 
 * Mike Furr in diamondback-ruby.
 *
 * todo: 
 *  - [AST Format of the Whitequark parser](https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md)
 *  - https://rubygems.org/gems/ast
 *  - new AST format in RubyVM in ruby 2.6 (see wikipedia page on Ruby)
 * 
 * history:
 *  - 2010 diamondback-ruby latest version
 *  - 2020 integrate in pfff diamondback-ruby parser, AST and IL (called cfg)
 *  - lots of small refactorings, see modif-orig.txt
 *)

(*****************************************************************************)
(* Names *)
(*****************************************************************************)

(* ------------------------------------------------------------------------- *)
(* Token/info *)
(* ------------------------------------------------------------------------- *)
type tok = Parse_info.t
 (* with tarzan *)

(* a shortcut to annotate some information with token/position information *)
type 'a wrap = 'a * tok

(* round(), square[], curly{}, angle<> brackets *)
type 'a bracket = tok * 'a * tok

(* ------------------------------------------------------------------------- *)
(* Ident/name *)
(* ------------------------------------------------------------------------- *)

type ident = string wrap

type id_kind = 
  | ID_Lowercase (* prefixed by [a-z] or _ *)
  | ID_Uppercase (* prefixed by [A-Z] *)
  | ID_Instance  (* prefixed by @ *)
  | ID_Class     (* prefixed by @@ *)
  | ID_Global    (* prefixed by $ *)
  | ID_Builtin   (* prefixed by $, followed by non-alpha *)
  | ID_Assign of id_kind (* postfixed by = *)

(* ------------------------------------------------------------------------- *)
(* Operators *)
(* ------------------------------------------------------------------------- *)
type unary_op = 
  | Op_UMinus    (* -x *)  | Op_UPlus     (* +x *)
  | Op_UBang     (* !x *)
  | Op_UTilde    (* ~x *)
  | Op_UNot      (* not x *)
  | Op_UAmper    (* & *)
  | Op_UStar     (* * *)

  | Op_UScope    (* ::x *)


type binary_op = 
  | Op_PLUS     (* + *)  | Op_MINUS    (* - *)
  | Op_TIMES    (* * *)  | Op_REM      (* % *)  | Op_DIV      (* / *)
  | Op_CMP      (* <=> *)
  | Op_EQ   (* == *)  | Op_EQQ      (* === *)
  | Op_NEQ      (* != *)
  | Op_GEQ      (* >= *)  | Op_LEQ      (* <= *)
  | Op_LT       (* < *)  | Op_GT       (* > *)
  | Op_AND      (* && *)  | Op_OR   (* || *)
  | Op_BAND     (* & *)  | Op_BOR      (* | *)
  | Op_MATCH    (* =~ *)
  | Op_NMATCH   (* !~ *)
  | Op_XOR      (* ^ *)
  | Op_POW      (* ** *)
  | Op_kAND     (* and *)  | Op_kOR      (* or *)

  | Op_ASSIGN   (* = *)
  | Op_OP_ASGN of binary_op  (* +=, -=, ... *)

  | Op_DOT      (* . *)
  | Op_SCOPE    (* :: *)

  | Op_ASSOC    (* => *)

  | Op_AREF     (* [] *)
  | Op_ASET     (* []= *)
  | Op_LSHIFT   (* < < *)  | Op_RSHIFT   (* > > *)

  | Op_DOT2     (* .. *)
  | Op_DOT3     (* ... *)

(*****************************************************************************)
(* Expression *)
(*****************************************************************************)

type expr = 
  | Literal of literal

  | Id of ident * id_kind
  | Operator of binary_op wrap
  | UOperator of unary_op wrap

  | Hash of bool * expr list bracket
  | Array of expr list bracket
  | Tuple of expr list * tok

  | Unary of unary_op wrap * expr
  | Binop of expr * binary_op wrap * expr
  | Ternary of expr * tok (* ? *) * expr * tok (* : *) * expr

  | Call of expr * expr list * expr option * tok

  (* true = {}, false = do/end *)
  | CodeBlock of bool bracket * formal_param list option * stmts * tok

  | S of stmt
  | D of definition

and literal = 
  | Bool of bool wrap
  | Num of string wrap
  | Float of string wrap

  | String of string_kind wrap
  | Regexp of (interp_string * string) wrap

  | Atom of interp_string wrap

  | Nil of tok | Self of tok


  and string_kind = 
    | Single of string
    | Double of interp_string
    | Tick of interp_string

  and interp_string = string_contents list

    and string_contents = 
      | StrChars of string
      | StrExpr of expr

(*****************************************************************************)
(* Statement *)
(*****************************************************************************)
(* Note that in Ruby everything is an expr, but I still like to split expr
 * with the different "subtypes" stmt and definition.
 * Note that ../analyze/il_ruby.ml has proper separate expr and stmt types.
 *)
and stmt =
  | Empty
  | Block of stmts * tok

  | If of tok * expr * stmts * stmts option2
  | While of tok * bool * expr * stmts
  | Until of tok * bool * expr * stmts
  | Unless of tok * expr * expr list * stmts
  | For of tok * formal_param list * expr * stmts

  | Return of tok * expr list (* option *)
  | Yield of tok * expr list (* option *)

  | Case of tok * case_block

  | ExnBlock of body_exn * tok

  and case_block = {
    case_guard : expr;
    case_whens: (expr list * stmts) list;
    case_else: stmts option2;
  }
  
  and body_exn = {
    body_exprs: stmts;
    rescue_exprs: (expr * expr) list;
    ensure_expr: stmts option2;
    else_expr: stmts option2;
  }

and stmts = expr list

(* TODO: (tok * 'a) option *)
and 'a option2 = 'a

(*****************************************************************************)
(* Definitions *)
(*****************************************************************************)
and definition =
  | ModuleDef of tok * expr * body_exn
  | ClassDef of tok * expr * inheritance_kind option * body_exn
  | MethodDef of tok * expr * formal_param list * body_exn

  | BeginBlock of tok * stmts bracket
  | EndBlock of tok * stmts bracket

  | Alias of tok * expr * expr
  | Undef of tok * expr list

  and formal_param = 
    | Formal_id of expr
    | Formal_amp of tok * ident
    | Formal_star of tok * ident (* as in *x *)
    | Formal_rest of tok (* just '*' *)
    | Formal_tuple of formal_param list bracket
    | Formal_default of ident * tok (* = *) * expr
  
  and inheritance_kind = 
    | Class_Inherit of expr
    | Inst_Inherit of expr

 (* with tarzan *)

(*****************************************************************************)
(* Type *)
(*****************************************************************************)
(* Was called Annotation in diamondback-ruby but was using its own specific
 * comment format. 
 * less: maybe leverage the new work on gradual typing of Ruby in
 * Sorbet and steep?
 *)

(*****************************************************************************)
(* Toplevel *)
(*****************************************************************************)

type program = stmts
 (* with tarzan *)
