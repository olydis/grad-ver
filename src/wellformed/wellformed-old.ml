open Core
open Ast
open Utility

(****************************************************************************************************************************)
(* utilities *)

(* exceptions *)

(* malformed *)
exception Malformed of string
(* invalid *)
exception Invalid_field_reference  of expression_field_reference
exception Invalid_access_check     of concrete_access_check
exception Invalid_field_assignment of statement_field_assignment
exception Invalid_new_object       of statement_new_object
(* undefined/undeclared *)
exception Class_undefined     of id
exception Field_undeclared    of class_ * id
exception Predicate_undefined of class_ option * id
exception Method_undefined    of class_ * id
exception Variable_undeclared of id
(* mismatch *)
exception Type_mismatch  of { left: type_; right: type_ }
exception Class_mismatch of { left: class_; right: class_ }

(* arguments length mismatch *)
exception Method_call_arguments_length_mismatch  of method_   * statement_method_call
exception Fold_arguments_length_mismatch         of predicate * statement_fold
exception Unfold_arguments_length_mismatch       of predicate * statement_unfold
exception Unfolding_in_arguments_length_mismatch of predicate * concrete_unfolding_in

(****************************************************************************************************************************)
(* check utilities *)

let check : bool -> exn -> unit =
  fun b e -> if b then () else raise e

let checkSome : 'a option -> exn -> unit =
  fun opt e -> match opt with Some a -> () | None -> raise e

let getSome : 'a option -> exn -> 'a =
  fun opt e -> match opt with Some a -> a | None -> raise e

let checkFold : ('a -> unit) -> 'a List.t -> unit =
  fun test -> List.fold ~init:() ~f:(fun () x -> test x)

(****************************************************************************************************************************)
(* type *)

let string_of_type_ : type_ -> string =
  function
  | Int       -> "Int"
  | Bool      -> "Bool"
  | Class cls -> "Class " ^ cls
  | Top       -> "Top"

let checkTypeMatch : type_ -> type_ -> unit =
  fun typ typ' ->
  check (eqType typ typ') @@
  Type_mismatch { left=typ; right=typ' }

let checkClassMatch : class_ -> class_ -> unit =
  fun cls cls' ->
  check (eqClass cls cls') @@
  Class_mismatch { left=cls; right=cls' }

(****************************************************************************************************************************)
(* context *)

type typecontext = (expression, type_)

module TypeContext =
struct

end

type 'a context = (id, 'a) String.Table.t_

let findExn : 'a context -> id -> exn -> 'a =
  fun ctx k e ->
  match Hashtbl.find ctx k with
  | Some d -> d
  | None -> raise e

let createContext : unit -> 'a context = String.Table.create

(*****************************************************************)
(* context of class definitions *)

let class_context : class_ context = createContext ();;

let setClass : id -> class_ -> unit = fun id cls -> Hashtbl.set class_context ~key:id ~data:cls
let getClass : id -> class_ = fun id -> findExn class_context id @@ Class_undefined id

let getField : id -> id -> class_field =
  fun clsid fldid ->
  let cls = getClass clsid in
  getSome (List.find cls.fields ~f:(fun fld -> eqId fld.id fldid)) @@
    Field_undeclared (cls, fldid)

let getFieldType : id -> id -> type_ =
  fun clsid fldid -> (getField clsid fldid).type_

let getPredicate : id -> id -> predicate =
  fun clsid predid ->
  let cls = getClass clsid in
  getSome (List.find cls.predicates ~f:(fun pred' -> eqId pred'.id predid)) @@
    Predicate_undefined (Some cls, predid)

let getPredicateArguments : id -> id -> argument list = fun clsid predid -> (getPredicate clsid predid).arguments
let getPredicateFormula   : id -> id -> formula       = fun clsid predid -> (getPredicate clsid predid).formula

let getMethod : id -> id -> method_ =
  fun clsid methid ->
  let cls = getClass clsid in
  getSome (List.find cls.methods ~f:(fun meth -> eqId meth.id methid)) @@
    Method_undefined (cls, methid)

(*****************************************************************)
(* context of variable declarations *)

let variable_context : type_ context = createContext ();;

let setVariableType : id -> type_ -> unit = fun id typ -> Hashtbl.set variable_context ~key:id ~data:typ
let getVariableType : id -> type_ = fun id -> findExn variable_context id @@ Variable_undeclared id

(****************************************************************************************************************************)
(* types *)

(* TODO *)
let rec synthesizeType expr =
  failwith "unimplemented"

(* let rec synthesizeType : expression -> type_ =
  fun e ->
  match e with
  | Variable x ->
    begin
      match x with
      | Result -> getVariableType "result"
      | Id id  -> getVariableType id
      | Old id -> getVariableType id
      | This   -> getVariableType "this"
    end
  | Value v ->
    begin
      match v with
      | Int _     -> Int
      | Bool _    -> Bool
      | Object id -> Class id
      | Null      -> failwith "what should null's type be here? shouldn't ever get here..." (* TODO *)
    end
  | Operation oper ->
    begin
      let ltyp  = synthesizeType oper.left in
      let rtyp = synthesizeType oper.right in
      match oper.operator with
      | Add | Sub | Mul | Div ->
        if (eqType ltyp rtyp) && (eqType ltyp Int)
        then Int
        else raise @@ Type_mismatch { left=ltyp; right=rtyp }
      | And | Or ->
        if (eqType ltyp rtyp) && (eqType ltyp Bool)
        then Bool
        else raise @@ Type_mismatch { left=ltyp; right=rtyp }
    end
  | Comparison comp ->
    begin
      let ltyp = synthesizeType comp.left in
      let rtyp = synthesizeType comp.right in
      if eqType ltyp rtyp
      then Top
      else raise @@ Type_mismatch { left=ltyp ; right=rtyp }
    end
  | Field_reference fldref ->
    begin
      let baseType = synthesizeType fldref.base in
      match baseType with
      | Class cls -> getFieldType cls fldref.field
      | _ -> raise @@ Invalid_field_reference fldref
    end *)

(****************************************************************************************************************************)
(* infer predicate class *)

(* TODO: how to infer predicate class just from the placement of the predicate check? *)
let inferPredicateClass : predicate_check -> class_ =
  fun predchk -> failwith "todo: infer predcate class from class context"

(****************************************************************************************************************************)
(* check expression *)

let rec checkExpression expr =
  failwith "unimplemented"

(* let rec checkExpression : expression -> unit =
  fun expr ->
  match expr with
  | Variable var ->
    begin
      match var with
      | Old id -> ignore @@ getVariableType id (* variable is declared *)
      | _ -> ()
    end
  | Value vlu ->
    begin
      match vlu with
      | Object id -> ignore @@ getVariableType id (* variable is declared *)
      | _ -> ()
    end
  | Operation oper ->
    ignore @@ synthesizeType expr (* type checks *)
  | Comparison comp ->
    ignore @@ synthesizeType expr (* type checks *)
  | Field_reference fldref ->
    (* form: `o.f` where `clsid` is `o`'s class id *)
    let baseCase clsid = ignore @@ getField clsid fldref.field in
    (* form: `e.o.f` where `baseref` is `e.o` *)
    let inductiveCase baseref =
      checkExpression (Field_reference baseref);
      let basetyp   = synthesizeType (Field_reference baseref) in
      let baseclsid =
        begin
          match basetyp with
          | Class id -> id
          | _ -> raise @@ Invalid_field_reference baseref
        end in
      ignore @@ getField baseclsid fldref.field
    in
    begin
      match fldref.base with
      | Variable var -> baseCase (getExpressionId @@ Variable var)
      | Value    vlu -> baseCase (getExpressionId @@ Value    vlu)
      | Field_reference baseref -> inductiveCase baseref
      | _ -> raise @@ Invalid_field_reference fldref
    end *)

(****************************************************************************************************************************)
(* check formula *)

let rec checkConcrete phi =
  failwith "unimplemented"

(* let rec checkConcrete : concrete -> unit =
  fun phi ->
  match phi with
  | Expression expr ->
    checkExpression expr
  | Predicate_check predchk ->
    let cls = inferPredicateClass predchk in
    ignore @@ getPredicate cls.id predchk.predicate
  | Access_check accchk ->
    begin
      match synthesizeType accchk.base with
      | Class cls -> ignore @@ getField accchk.field cls
      | _ -> raise @@ Invalid_access_check accchk
    end
  | Operation oper ->
    checkConcrete oper.left;
    checkConcrete oper.right;
  | If_then_else ite ->
    checkExpression     ite.condition;
    checkConcrete ite.then_;
    checkConcrete ite.else_
  | Unfolding_in unfolin ->
    let predchk = unfolin.predicate_check in
    let pred = getPredicate (inferPredicateClass unfolin.predicate_check).id predchk.predicate in
    (* given argument count matches expected *)
    check (List.length pred.arguments = List.length predchk.arguments) @@
      Unfolding_in_arguments_length_mismatch (pred, unfolin);
    (* given arguments have correct types *)
    checkFold (fun ((arg,expr):argument*expression) -> checkTypeMatch arg.type_ (synthesizeType expr)) @@
      List.zip_exn pred.arguments predchk.arguments;
    (* body formula *)
    checkConcrete unfolin.formula *)

and checkFormula phi =
  failwith "unimplemented"

(* and checkFormula : formula -> unit =
  fun phi ->
  match phi with
  | Imprecise phi -> checkConcrete phi
  | Concrete  phi -> checkConcrete phi *)

and checkContract ctrt =
  failwith "unimplemented"

(* let checkContract : contract -> unit =
  fun ctrt ->
  checkFormula ctrt.requires;
  checkFormula ctrt.ensures *)

(****************************************************************************************************************************)
(* statements *)

let rec checkStatement stmt =
  failwith "unimplemented"

(* let rec checkStatement : statement -> unit =
  fun stmt ->
  print_string "\n\n";
  Ast_pp.pp_statement Format.std_formatter stmt;
  match stmt with
  | Skip ->
    ()
  | Sequence seq ->
    checkFold checkStatement seq.statements;
  | Declaration decl ->
    setVariableType decl.id decl.type_
  | Assignment asmt ->
    let typ, typ' = getVariableType asmt.id, synthesizeType asmt.value in
    checkTypeMatch typ typ'
  | If_then_else ite ->
    checkExpression ite.condition;
    checkStatement  ite.then_;
    checkStatement  ite.else_
  | While_loop wl ->
    checkFormula    wl.invariant;
    checkExpression wl.condition;
    checkStatement  wl.body
  | Field_assignment fasmt ->
    let basetyp = getVariableType fasmt.base in
    begin
      match basetyp with
      | Class cls ->
        let fldtyp = getFieldType fasmt.base fasmt.field in
        let srctyp = getVariableType fasmt.source in
        checkTypeMatch fldtyp srctyp
      | _ -> raise @@ Invalid_field_assignment fasmt
    end
  | New_object newobj ->
    let vartyp = getVariableType newobj.id in
    let cls    = getClass        newobj.class_ in
    begin
      match vartyp with
      | Class typcls' ->
        let cls' = getClass typcls' in
        checkClassMatch cls cls'
      | _ -> raise @@ Invalid_new_object newobj
    end
  | Method_call methcall ->
    let meth   = getMethod methcall.base methcall.method_ in
    let vartyp = getVariableType methcall.target in
    (* target variable type matches return type  *)
    checkTypeMatch meth.type_ vartyp;
    (* given argument count matches expected *)
    check (List.length meth.arguments = List.length methcall.arguments) @@
      Method_call_arguments_length_mismatch (meth, methcall);
    (* given arguments have correct types *)
    checkFold (fun ((arg,id):argument*id) -> checkTypeMatch arg.type_ (getVariableType id)) @@
      List.zip_exn meth.arguments methcall.arguments;
  | Assertion asrt ->
    checkConcrete asrt.concrete
  | Release rls ->
    checkConcrete rls.concrete
  | Hold hld ->
    checkFormula   hld.formula;
    checkStatement hld.body
  | Fold fol ->
    let cls = inferPredicateClass fol.predicate_check in
    let pred = getPredicate cls.id fol.predicate_check.predicate in
    (* given argument count matches expected *)
    check (List.length pred.arguments = List.length fol.predicate_check.arguments) @@
      Fold_arguments_length_mismatch (pred, fol);
    (* given arguments have correct types *)
    checkFold (fun ((arg,expr):argument*expression) -> checkTypeMatch arg.type_ (synthesizeType expr)) @@
      List.zip_exn pred.arguments fol.predicate_check.arguments
  | Unfold unfol ->
    let cls = inferPredicateClass unfol.predicate_check in
    let pred = getPredicate cls.id unfol.predicate_check.predicate in
    (* given argument count matches expected *)
    check (List.length pred.arguments = List.length unfol.predicate_check.arguments) @@
      Unfold_arguments_length_mismatch (pred, unfol);
    (* given arguments have correct types *)
    checkFold (fun ((arg,expr):argument*expression) -> checkTypeMatch arg.type_ (synthesizeType expr)) @@
      List.zip_exn pred.arguments unfol.predicate_check.arguments *)

(****************************************************************************************************************************)
(* check class *)

let rec checkPredicate pred =
  failwith "unimplemented"

(* let rec checkPredicate : predicate -> unit =
  fun pred ->
  checkFormula pred.formula *)

let checkMethod meth =
  failwith "unimplemented"

(* let checkMethod : method_ -> unit =
  fun meth ->
  checkContract meth.dynamic;
  checkContract meth.static;
  checkStatement meth.body *)

let checkClass cls =
  failwith "unimplemented"

(* let rec checkClass : class_ -> unit =
  fun cls ->
  setClass cls.id cls;
  checkFold checkPredicate cls.predicates;
  checkFold checkMethod cls.methods *)

(****************************************************************************************************************************)
(* program *)

let checkProgram prgm =
  failwith "unimplemented"

(* let checkProgram : program -> unit =
  fun prgm ->
  checkFold checkClass prgm.classes;
  checkStatement prgm.statement *)