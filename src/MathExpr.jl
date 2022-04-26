module MathExpr
# we use the new way to implement, following the scheme for multiop
export SymbolPool, evalPool, Term, TermPool, evalTerm, SymExpr, addTerm!, addExpr, mulExpr, ExprEngine, SymExpr, simplify,is_zero, __default__engine__map__
"""
store all the symbols 
"""
struct SymbolPool
    array::Array{Symbol,1}
    sym_to_idx::Dict{Symbol, Int}
end

function SymbolPool()
     SymbolPool(Array{Symbol,1}(),Dict{Symbol,Int}())
end

function Base.show(io::IO, pool::SymbolPool)
    print(io,"SymbolPool$(pool.array)")
end


"""
evaluate sym from sympool, return the index
if not exist, add the symbol
"""
function evalPool(sym::Symbol, sympool::SymbolPool)
    if(!haskey(sympool.sym_to_idx,sym))
        push!(sympool.array,sym)
        sympool.sym_to_idx[sym]=length(sympool.array)
    end
    sympool.sym_to_idx[sym]
end

function evalPool(idx::Int, sympool::SymbolPool)
    if(idx>length(sympool.array) || idx<0)
        error("idx $(idx) is out of range for $(sympool)")
    else
        return sympool.array[idx]
    end    
end

function (sympool::SymbolPool)(x)
    evalPool(x,sympool)
end

struct Term
    sympool::SymbolPool
    value::Array{Int,1}
end

function Base.show(io::IO,term::Term)
    if(length(term.value)==0)
        print(io,"Î")
    else
        print(io,join(term.sympool.(term.value),"*"))
    end    
end


function Term(sympool::SymbolPool,input::Array{Symbol,1})
    Term(sympool, sort(sympool.(input)))
end

function Base.:(==)(term1::Term, term2::Term)
    term1.sympool==term2.sympool && term1.value==term2.value
end

function Base.isequal(term1::Term,term2::Term)
    term1==term2
end

function Base.hash(term::Term)
    hash(term.value)
end



"""
once we have the sympool, we only need to store the index
"""
struct TermPool
    array::Array{Term,1}
    term_to_idx::Dict{Term,Int}
end

function TermPool()
    TermPool(Array{Term,1}(),Dict{Term,Int}())
end


function Base.show(io::IO, pool::TermPool)
    print(io,"SymbolPool$(pool.array)")
end

function evalTerm(term::Term, termpool::TermPool)
    if(!haskey(termpool.term_to_idx,term))
        push!(termpool.array, term)
        termpool.term_to_idx[term]=length(termpool.array)
    end
    termpool.term_to_idx[term]
end

function evalTerm(idx::Int, termpool::TermPool)
    if(idx>length(termpool.array) || idx<0)
        error("idx $(idx) is out of range for $(termpool)")
    else
        return termpool.array[idx]
    end    
end

function (termpool::TermPool)(x)
    evalTerm(x,termpool)
end

"""
we could multiply two terms
"""
function Base.:(*)(term1::Term, term2::Term)
    if(term1.sympool!=term2.sympool)
        error("does not support * for two terms with different SymbolPool")
    else
        Term(term1.sympool,sort!([term1.value...,term2.value...]))
    end    
end

"""
We assume the coefficient is float
"""
struct SymExpr
    termpool::TermPool
    coefficient::Dict{Int,Float64}
end


# function Base.convert(::Type{SymExpr},x::SymExpr)
#     x
# end



function SymExpr(termpool::TermPool)
    SymExpr(termpool, Dict{Int,Float64}())
end

function show_term(v,t)
    if(v==1.0)
        "$(t)"
    else
        "$(v)*$(t)"
    end    
end

function Base.show(io::IO, expr::SymExpr)
    if(length(expr.coefficient)>0)
        print(io,join([show_term(v,expr.termpool(k))  for (k,v) in expr.coefficient],"+"))
    else
        print(io,"0")
    end    
end

"""
add term to expr, this will modify expr itself.
"""
function addTerm!(expr::SymExpr,c::Number, term::Term)
    addTerm!(expr,c,expr.termpool(term))
end

function addTerm!(expr::SymExpr,c::Number, idx::Int)
    if(!haskey(expr.coefficient,idx))
        expr.coefficient[idx]=0.0
    end
    expr.coefficient[idx]+=c
    expr
end

"""
add two expr to a new SymExpr
"""
function addExpr(expr1::SymExpr, expr2::SymExpr)
    if(expr1.termpool!=expr2.termpool)
        error("does not support two different TermPool right now")
    else
        result=SymExpr(expr1.termpool)
        for (k,v) in expr1.coefficient
            addTerm!(result,v,k)
        end        
        for (k,v) in expr2.coefficient
            addTerm!(result,v,k)
        end
        return result
    end
end

function Base.:(+)(expr1::SymExpr,expr2::SymExpr)
    addExpr(expr1,expr2)
end

"""
implement multiplication for two expr
"""
function mulExpr(expr1::SymExpr, expr2::SymExpr)
    if(expr1.termpool!=expr2.termpool)
        error("does not support two different TermPool right now")
    else
        result=SymExpr(expr1.termpool)
        for (k1,v1) in expr1.coefficient
            for (k2,v2) in expr2.coefficient
                t1=expr1.termpool(k1)
                t2=expr2.termpool(k2)
                t=t1*t2
                addTerm!(result,v1*v2,t)
            end
        end
        return result
    end
end

"""
overload the * operator
"""
function Base.:(*)(expr1::SymExpr, expr2::SymExpr)
    mulExpr(expr1,expr2)
end


# now, we should add some interface for the library.

"""
store all the symbols and terms
"""
struct ExprEngine
    sympool::SymbolPool
    termpool::TermPool
end

function ExprEngine()
    result=ExprEngine(SymbolPool(), TermPool())
    result(1.0)                 # ensure not termpool not empty
    result
end

"""
convert Number to SymExpr
"""
function SymExpr(engine::ExprEngine, c::Number)
    result=SymExpr(engine.termpool)
    addTerm!(result,c,Term(engine.sympool,[]))
    result
end

function SymExpr(engine::ExprEngine, sym::Symbol)
    result=SymExpr(engine.termpool)
    addTerm!(result,1.0,Term(engine.sympool,[sym]))
    result
end

function (engine::ExprEngine)(x)
    SymExpr(engine,x)
end

"""
we ensure that x.termpool is not empty when we first create engine
"""
function ExprEngine(x::SymExpr)
    ExprEngine(x.termpool.array[1].sympool,x.termpool)
end


function Base.:(-)(x::SymExpr)
    ((ExprEngine(x))(-1.0))*x
end

function Base.:(-)(x::SymExpr,y::SymExpr)
    x+(-y)
end

"""
remore the zero terms
"""
function simplify(x::SymExpr)
    zeros_terms=[k for(k,v) in x.coefficient if v==0.0]    
    [delete!(x.coefficient,k)  for k in zeros_terms]
    x
end

function is_zero(x::SymExpr)
    length(x.coefficient)==0
end


function Base.:(+)(x::SymExpr, c::Number)
    x+((ExprEngine(x))(c))
end

function Base.:(+)( c::Number,x::SymExpr)
    x+c
end

function Base.:(-)(x::SymExpr, c::Number)
    x+(-c)
end

function Base.:(-)( c::Number,x::SymExpr)
    c+(-x)
end

function Base.:(*)(c::Number, x::SymExpr)
    x*((ExprEngine(x))(c))
end

function Base.:(*)(x::SymExpr,c::Number)
    c*x
end


function Base.convert(::Type{SymExpr},x::Number)
    __default__engine__map__["default"](x)
end

"""
expr=__default__engine__map__["default"](3.5)
"""
function Base.convert(::Type{Float64}, expr::SymExpr)
    if(keys(__default__engine__map__["default"](1.0).coefficient)==keys(expr.coefficient))
        return collect(expr.coefficient)[1][2]
    else
        error("can't convert $(expr) to Float!")
    end    
end



"""
for convient, a global default engine.
"""
__default__engine__map__=Dict("default"=>ExprEngine())

end # module
