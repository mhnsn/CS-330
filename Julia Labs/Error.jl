module Error

export LispError

type LispError <: Exception
    msg::AbstractString
end

end #module
