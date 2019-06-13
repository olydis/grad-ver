(** ast.proto Types *)



(** {2 Types} *)

type type_ =
  | Int
  | Bool
  | Class of string
  | Top

type class_field = {
  type_ : type_;
  id : string;
}

type argument = {
  type_ : type_;
  id : string;
}

type variable =
  | Result
  | Id of string
  | Old of string
  | This

type value =
  | Int of int32
  | Bool of bool
  | Object of string
  | Null

type expression_operator =
  | Add 
  | Sub 
  | Mul 
  | Div 
  | And 
  | Or 

type expression_comparer =
  | Neq 
  | Eq 
  | Lt 
  | Gt 
  | Le 
  | Ge 

type expression =
  | Variable of variable
  | Value of value
  | Operation of expression_operation
  | Comparison of expression_comparison
  | Field_reference of expression_field_reference

and expression_operation = {
  operator : expression_operator;
  left : expression;
  right : expression;
}

and expression_comparison = {
  comparer : expression_comparer;
  left : expression;
  right : expression;
}

and expression_field_reference = {
  base : expression;
  field : string;
}

type predicate_check = {
  predicate : string;
  arguments : expression list;
  class_ : string option;
}

type concrete_access_check = {
  base : expression;
  field : string;
}

type concrete_operator =
  | And 
  | Sep 

type concrete =
  | Expression of expression
  | Predicate_check of predicate_check
  | Access_check of concrete_access_check
  | Operation of concrete_operation
  | If_then_else of concrete_if_then_else
  | Unfolding_in of concrete_unfolding_in

and concrete_operation = {
  operator : concrete_operator;
  left : concrete;
  right : concrete;
}

and concrete_if_then_else = {
  condition : expression;
  then_ : concrete;
  else_ : concrete;
}

and concrete_unfolding_in = {
  predicate_check : predicate_check;
  formula : concrete;
}

type formula =
  | Concrete of concrete
  | Imprecise of concrete

type predicate = {
  id : string;
  arguments : argument list;
  formula : formula;
}

type contract = {
  requires : formula;
  ensures : formula;
}

type statement_declaration = {
  type_ : type_;
  id : string;
}

type statement_assignment = {
  id : string;
  value : expression;
}

type statement_field_assignment = {
  base : string;
  field : string;
  source : string;
}

type statement_new_object = {
  id : string;
  class_ : string;
}

type statement_method_call = {
  target : string;
  base : string;
  method_ : string;
  arguments : string list;
  class_ : string option;
}

type statement_assertion = {
  concrete : concrete;
}

type statement_release = {
  concrete : concrete;
}

type statement_fold = {
  predicate_check : predicate_check;
}

type statement_unfold = {
  predicate_check : predicate_check;
}

type statement =
  | Skip
  | Sequence of statement_sequence
  | Declaration of statement_declaration
  | Assignment of statement_assignment
  | If_then_else of statement_if_then_else
  | While_loop of statement_while_loop
  | Field_assignment of statement_field_assignment
  | New_object of statement_new_object
  | Method_call of statement_method_call
  | Assertion of statement_assertion
  | Release of statement_release
  | Hold of statement_hold
  | Fold of statement_fold
  | Unfold of statement_unfold

and statement_sequence = {
  statements : statement list;
}

and statement_if_then_else = {
  condition : expression;
  then_ : statement;
  else_ : statement;
}

and statement_while_loop = {
  condition : expression;
  invariant : formula;
  body : statement;
}

and statement_hold = {
  formula : formula;
  body : statement;
}

type method_ = {
  type_ : type_;
  id : string;
  arguments : argument list;
  dynamic : contract;
  static : contract;
  body : statement;
}

type class_ = {
  id : string;
  super : string;
  fields : class_field list;
  predicates : predicate list;
  methods : method_ list;
}

type program = {
  classes : class_ list;
  statement : statement;
}


(** {2 Default values} *)

val default_type_ : unit -> type_
(** [default_type_ ()] is the default value for type [type_] *)

val default_class_field : 
  ?type_:type_ ->
  ?id:string ->
  unit ->
  class_field
(** [default_class_field ()] is the default value for type [class_field] *)

val default_argument : 
  ?type_:type_ ->
  ?id:string ->
  unit ->
  argument
(** [default_argument ()] is the default value for type [argument] *)

val default_variable : unit -> variable
(** [default_variable ()] is the default value for type [variable] *)

val default_value : unit -> value
(** [default_value ()] is the default value for type [value] *)

val default_expression_operator : unit -> expression_operator
(** [default_expression_operator ()] is the default value for type [expression_operator] *)

val default_expression_comparer : unit -> expression_comparer
(** [default_expression_comparer ()] is the default value for type [expression_comparer] *)

val default_expression : unit -> expression
(** [default_expression ()] is the default value for type [expression] *)

val default_expression_operation : 
  ?operator:expression_operator ->
  ?left:expression ->
  ?right:expression ->
  unit ->
  expression_operation
(** [default_expression_operation ()] is the default value for type [expression_operation] *)

val default_expression_comparison : 
  ?comparer:expression_comparer ->
  ?left:expression ->
  ?right:expression ->
  unit ->
  expression_comparison
(** [default_expression_comparison ()] is the default value for type [expression_comparison] *)

val default_expression_field_reference : 
  ?base:expression ->
  ?field:string ->
  unit ->
  expression_field_reference
(** [default_expression_field_reference ()] is the default value for type [expression_field_reference] *)

val default_predicate_check : 
  ?predicate:string ->
  ?arguments:expression list ->
  ?class_:string option ->
  unit ->
  predicate_check
(** [default_predicate_check ()] is the default value for type [predicate_check] *)

val default_concrete_access_check : 
  ?base:expression ->
  ?field:string ->
  unit ->
  concrete_access_check
(** [default_concrete_access_check ()] is the default value for type [concrete_access_check] *)

val default_concrete_operator : unit -> concrete_operator
(** [default_concrete_operator ()] is the default value for type [concrete_operator] *)

val default_concrete : unit -> concrete
(** [default_concrete ()] is the default value for type [concrete] *)

val default_concrete_operation : 
  ?operator:concrete_operator ->
  ?left:concrete ->
  ?right:concrete ->
  unit ->
  concrete_operation
(** [default_concrete_operation ()] is the default value for type [concrete_operation] *)

val default_concrete_if_then_else : 
  ?condition:expression ->
  ?then_:concrete ->
  ?else_:concrete ->
  unit ->
  concrete_if_then_else
(** [default_concrete_if_then_else ()] is the default value for type [concrete_if_then_else] *)

val default_concrete_unfolding_in : 
  ?predicate_check:predicate_check ->
  ?formula:concrete ->
  unit ->
  concrete_unfolding_in
(** [default_concrete_unfolding_in ()] is the default value for type [concrete_unfolding_in] *)

val default_formula : unit -> formula
(** [default_formula ()] is the default value for type [formula] *)

val default_predicate : 
  ?id:string ->
  ?arguments:argument list ->
  ?formula:formula ->
  unit ->
  predicate
(** [default_predicate ()] is the default value for type [predicate] *)

val default_contract : 
  ?requires:formula ->
  ?ensures:formula ->
  unit ->
  contract
(** [default_contract ()] is the default value for type [contract] *)

val default_statement_declaration : 
  ?type_:type_ ->
  ?id:string ->
  unit ->
  statement_declaration
(** [default_statement_declaration ()] is the default value for type [statement_declaration] *)

val default_statement_assignment : 
  ?id:string ->
  ?value:expression ->
  unit ->
  statement_assignment
(** [default_statement_assignment ()] is the default value for type [statement_assignment] *)

val default_statement_field_assignment : 
  ?base:string ->
  ?field:string ->
  ?source:string ->
  unit ->
  statement_field_assignment
(** [default_statement_field_assignment ()] is the default value for type [statement_field_assignment] *)

val default_statement_new_object : 
  ?id:string ->
  ?class_:string ->
  unit ->
  statement_new_object
(** [default_statement_new_object ()] is the default value for type [statement_new_object] *)

val default_statement_method_call : 
  ?target:string ->
  ?base:string ->
  ?method_:string ->
  ?arguments:string list ->
  ?class_:string option ->
  unit ->
  statement_method_call
(** [default_statement_method_call ()] is the default value for type [statement_method_call] *)

val default_statement_assertion : 
  ?concrete:concrete ->
  unit ->
  statement_assertion
(** [default_statement_assertion ()] is the default value for type [statement_assertion] *)

val default_statement_release : 
  ?concrete:concrete ->
  unit ->
  statement_release
(** [default_statement_release ()] is the default value for type [statement_release] *)

val default_statement_fold : 
  ?predicate_check:predicate_check ->
  unit ->
  statement_fold
(** [default_statement_fold ()] is the default value for type [statement_fold] *)

val default_statement_unfold : 
  ?predicate_check:predicate_check ->
  unit ->
  statement_unfold
(** [default_statement_unfold ()] is the default value for type [statement_unfold] *)

val default_statement : unit -> statement
(** [default_statement ()] is the default value for type [statement] *)

val default_statement_sequence : 
  ?statements:statement list ->
  unit ->
  statement_sequence
(** [default_statement_sequence ()] is the default value for type [statement_sequence] *)

val default_statement_if_then_else : 
  ?condition:expression ->
  ?then_:statement ->
  ?else_:statement ->
  unit ->
  statement_if_then_else
(** [default_statement_if_then_else ()] is the default value for type [statement_if_then_else] *)

val default_statement_while_loop : 
  ?condition:expression ->
  ?invariant:formula ->
  ?body:statement ->
  unit ->
  statement_while_loop
(** [default_statement_while_loop ()] is the default value for type [statement_while_loop] *)

val default_statement_hold : 
  ?formula:formula ->
  ?body:statement ->
  unit ->
  statement_hold
(** [default_statement_hold ()] is the default value for type [statement_hold] *)

val default_method_ : 
  ?type_:type_ ->
  ?id:string ->
  ?arguments:argument list ->
  ?dynamic:contract ->
  ?static:contract ->
  ?body:statement ->
  unit ->
  method_
(** [default_method_ ()] is the default value for type [method_] *)

val default_class_ : 
  ?id:string ->
  ?super:string ->
  ?fields:class_field list ->
  ?predicates:predicate list ->
  ?methods:method_ list ->
  unit ->
  class_
(** [default_class_ ()] is the default value for type [class_] *)

val default_program : 
  ?classes:class_ list ->
  ?statement:statement ->
  unit ->
  program
(** [default_program ()] is the default value for type [program] *)