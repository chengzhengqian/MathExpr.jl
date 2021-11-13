]activate "/home/chengzhengqian/share_workspace/czq_julia_package/MathExpr"

using Revise
using MathExpr

sympool=SymbolPool()
sym=:x

x=zeros(0)
append!(x,1)
evalPool(:x,sympool)
evalPool(1,sympool)
sympool(:z)
input=[:x,:x,:z,:y]
term1=Term(sympool,[:x,:y])
term2=Term(sympool,[:y,:x])
term=term1
termpool=TermPool()

x=Term(sympool,[])
y=Term(sympool,[])
x==y
evalTerm(x,termpool)
evalTerm(1,termpool)
termpool(Term(sympool,[:x,:x,:y]))
x*x==x
expr=SymExpr(termpool)
SymExpr(termpool,Dict(termpool(term1)=>1.0))
expr1=addTerm!(expr,1.0,term)
expr2=addTerm!(expr,1.0,term)
expr3=addExpr(expr1,expr2)
expr1+expr2
expr4=mulExpr(expr1,expr2)+expr1
@time expr4*expr1+expr1+expr2
expr1.termpool
engine=ExprEngine()

x=SymExpr(engine,:x)
y=SymExpr(engine,:y)
x*y+x
engine(:x)

engine=ExprEngine()
c1=engine(1)
engine=ExprEngine(c1)
x=engine(:x)
x=x-x
simplify(engine(:y))
@time x*x+2.1
using SymEngine
x_=Basic("x")
@time y=x_*x_+2.1
@time y*y
x*1.0
1.0*x+x
# using Wick
# [InputNode(1),InputNode(2)]==[InputNode(1),InputNode(2)]
# x=expr(1.0)
# y=expr(:y)
# y+x
# x+y
# x=expr(0)
# x2=expr(0.0)
# x+x2
# is_number(a)
# is_atomic(x)
# is_atomic(x+y)
# expr("123")

# a=y+x
# b=y+x+x
# prod=expr(:*,1,:x,:y)
# [:x,:y]==[:x,:y]

# factor(expr(2.0))

# atomic_order(x)
# y=expr(:y)
# atomic_order(y)

# t=[expr(1),expr(:x),expr(3)]
# sort(t)
