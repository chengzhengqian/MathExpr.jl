module MathExpr
export expr, MExpr, is_number, is_atomic,factor, atomic_order

"""
this is simply a wrap over Expr (old way!!!)
We update the structure to mimic Expr, but not simplify just wrap around Expr.
We also need to change the code accordingly
unlike the julia, it seems more straightforward to set :+ or :* in head
"""
struct MExpr
    head::Symbol
    args::Array{Any,1}
end

# allow user to treat the Expr as
# we define three atomic types,
#  number, symbol, obj, (obj used to store any pointer like structure)
function expr(x::Number)
    MExpr(:number,[x])
end

function expr(x::Symbol)
    MExpr(:symbol,[x])
end

function expr(x::Any)
    MExpr(:obj,[x])
end

function expr(op::Symbol,paras...)
    MExpr(op,expr.(collect(paras)))
end



function Base.show(io::IO,x::MExpr)
    head=x.head
    if(head==:number)
        print(io,"$(x.args[1])")
    elseif(head==:+)
        print(io,join(x.args,:+))
    elseif(head==:*)
        print(io,join(x.args,:*))
    elseif(head==:symbol)
        print(io,"$(x.args[1])")
    elseif(head==:obj)
        print(io,"<$(x.args[1])>")
    else
        error("unsupported head $(head)")
    end    
end

function is_number(x::MExpr)
    if(x.head==:number)
        true
    else
        false
    end    
end

function get_number(x::MExpr)
    return x.args[1]
end

__ATOMIC_HEAD__=Set{Symbol}([:number,:symbol,:obj])
function is_atomic(x::MExpr)
    if(x.head in __ATOMIC_HEAD__)
        true
    else
        false
    end    
end


function Base.:+(x1::MExpr,x2::MExpr)
    if(is_number(x1) && is_number(x2))
        return expr(get_number(x1)+get_number(x2))
    elseif(is_number(x1))
        if(get_number(x1)==0||get_number(x1)==0.0)
            return x2
        end        
    elseif(is_number(x2))
        if(get_number(x2)==0||get_number(x2)==0.0)
            return x1
        end        
    end    
    MExpr(:+,[x1,x2])
end

"""
this product try to expand all of term
"""
function Base.:*(x1::MExpr,x2::MExpr)
    
end

function factor(x::MExpr)
    if(is_number(x))
        [x.args[1],[]]
    elseif(is_atomic(x))
        [1.0,x.args]
    elseif(x.head==:*)
        factor_prod(x)
    else
        error("factor should be called for a single term!\n")
    end    
end

__head_to_order__=Dict(:number=>1,:symbol=>2,:obj=>3)
"""
x should be an atomic type, return a tuple for comparision
used for sorted the product so we can have an unique basis
using a dictionary to simplify this.
"""
function atomic_order(x::MExpr)
    __head_to_order__[x.head],x.args[1]
end



function Base.:isless(x::MExpr,y::MExpr)
    if(is_atomic(x) && is_atomic(y))
        o1=atomic_order(x)
        o2=atomic_order(y)
        if(o1[1]!=o2[1])
            return o1[1]<o2[1]
        else
            return o1[2]<o2[2]
        end        
    else
        error("only support atomic comparision right now!\n")
    end    
end



# to facilate the
# we need to collect all products in a sum
# we first need to covert an atomic type for produce 
# function fact



end # module
