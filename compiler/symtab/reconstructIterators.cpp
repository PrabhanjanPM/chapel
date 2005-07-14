#include "reconstructIterators.h"
#include "symtab.h"
#include "stmt.h"
#include "expr.h"
#include "symbol.h"
#include "type.h"
#include "../traversals/traversal.h"

class ReconstructIteratorsHelper : public Traversal {
 public:
  Symbol* seq;
  ReconstructIteratorsHelper(Symbol* init_seq) {
    seq = init_seq;
  }
  void postProcessStmt(Stmt* stmt) {
    if (ReturnStmt* returnStmt = dynamic_cast<ReturnStmt*>(stmt)) {
      returnStmt->insertBefore(
        new ExprStmt(
          new ParenOpExpr(
            new MemberAccess(
              new Variable(seq),
              new UnresolvedSymbol("_append")),
            new AList<Expr>(
              returnStmt->expr->copy()))));
      if (returnStmt->yield) {
        returnStmt->remove();
      } else {
        returnStmt->replace(new ReturnStmt(new Variable(seq)));
      }
    }
  }
};


void ReconstructIterators::processSymbol(Symbol* sym) {
  FnSymbol* fn = dynamic_cast<FnSymbol*>(sym);

  if (!fn || fn->fnClass != FN_ITERATOR) {
    return;
  }

  Symbol* elt_type = dtUnknown->symbol;
  if (UnresolvedType* utype = dynamic_cast<UnresolvedType*>(fn->retType)) {
    elt_type = new UnresolvedSymbol(utype->names->v[0]);
  }

  Type* type =
    new ExprType(
      new ParenOpExpr(
        new Variable(
          new UnresolvedSymbol("seq")),
        new AList<Expr>(
          new Variable(elt_type))));

  DefExpr* def = Symboltable::defineSingleVarDef("_seq_result",
                                                 type,
                                                 NULL,
                                                 VAR_NORMAL,
                                                 VAR_VAR);
  Symbol* seq = def->sym;

  fn->body->body->insertAtHead(new ExprStmt(def));
  TRAVERSE(fn->body, new ReconstructIteratorsHelper(seq), true);
  fn->body->body->insertAtTail(new ReturnStmt(new Variable(seq)));
  fn->retType = dtUnknown;
}
