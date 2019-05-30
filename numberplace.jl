mutable struct Bord
    bord
    bord_kouho
    count_filled
    includeblock
    tate
    yoko
    unit
    function Bord(str)
        bord = zeros(Int, 9, 9)
        k = 1
        for i in 1:9
            for j in 1:9
                if str[k] != '0'
                    n = parse(Int, str[k])
                    bord[i,j] = n
                end
                k += 1
            end
        end
        bord_kouho = Dict()
        kakutei = []
        for i in 1:9
            for j in 1:9
                bord_kouho[(i, j)] = collect(1:9)
            end
        end 

        state = [[] for j in 1:9]
        for j in 1:9
            for i in 1:9
                push!(state[j], (i, j))
            end
        end

        tate = Dict()
        for i in 1:9
            for j in 1:9
                tate[(i, j)] = state[j]
            end
        end

        syoko = [[] for i in 1:9]
        for j in 1:9
            for i in 1:9
                push!(syoko[i], (i, j))
            end
        end

        yoko = Dict()
        for i in 1:9
            for j in 1:9
                yoko[(i, j)] = syoko[i]
            end
        end

        unit = Dict()
        for i in 1:9
            for j in 1:9
                unit[(i, j)] = getsqrunit((i, j))
            end
        end

        bd = new(zeros(Int, 9, 9), bord_kouho, 0, Dict(), tate, yoko, unit)
        for i in 1:9
            for j in 1:9
                if bord[i,j] > 0
                    insert_and_propagete(bd, (i, j), bord[i,j])
                end
            end
        end        
        bd
    end
end

function getsqrunit(p)
    tmp = (p .- 1) ./ 3
    r = (floor.(tmp)) .* 3
    r = r .+ 1
    y = [r[2],r[2] + 1,r[2] + 2]
    x = [r[1],r[1] + 1,r[1] + 2]
    unit = []
    for sx in x
        for sy in y
            push!(unit, (Int(sx), Int(sy)))
        end
    end
    return unit
end

function printbord(bd::Bord, orig = false)
    if !orig
        for i in 1:9
            println(bd.bord[i,:])
        end
    else
        for i in 1:9
            println(bd.bord_orig[i,:])
        end    
    end
end

function include_block(bd, p)
    if haskey(bd.includeblock, p)
        return bd.includeblock[p]
    end
    tmp = (p .- 1) ./ 3
    r = (floor.(tmp)) .* 3
    r = r .+ 1
    y = [r[2],r[2] + 1,r[2] + 2]
    x = [r[1],r[1] + 1,r[1] + 2]
    ret = []
    for sx in x
        for sy in y
            push!(ret, (Int(sx), Int(sy)))
        end
    end

    for i in 1:9
        push!(ret, (i, p[2]))
    end
    for j in 1:9
        push!(ret, (p[1], j))
    end
    bd.includeblock[p] = unique(ret)
    return ret
end

#eliminate cell p by x
function eliminate(bord, p, x)
    if !(x in bord.bord_kouho[p])
        return true
    end
    
    tmp = filter(y->y != x, bord.bord_kouho[p])
    bord.bord_kouho[p] = tmp
    if length(tmp) == 1
        if !insert_and_propagete(bord, p, tmp[1])
            return false
        end
        return true
    elseif length(tmp) == 0
        return false
    end
    
    for uu in (bord.tate, bord.yoko, bord.unit)
        kouho = []
        for ib in uu[p]
            if x in bord.bord_kouho[ib]
                if ib == p
                    continue
                end
                push!(kouho, ib)
            end
        end
        if length(kouho) == 0
            return false
        end
        if length(kouho) == 1
            return insert_and_propagete(bord, kouho[1], x)        
        end
    end
    return true
end

function insert_and_propagete(bord::Bord, p, x)
    if !(x in bord.bord_kouho[p])
        return false
    end
    if bord.bord[p[1],p[2]] == x
        return true
    end

    values = filter(y->y != x, bord.bord_kouho[p])
    bord.bord_kouho[p] = [x]
    bord.bord[p[1],p[2]] = x
    bord.count_filled += 1
    #=
    for sv in values
        if !eliminate(bord, p, sv)
            return false
        end
    end
    =#
    
    for sib in include_block(bord, p)
        if sib != p   
            if !eliminate(bord, sib, x)
                return false
            end
        end
    end        
    return true
end

function search(bd)    
    keys = []
    vals = []
    len = []
    for (sk, v) in bd.bord_kouho
        if length(v) >= 2
            push!(keys, sk)
            push!(vals, v)
            push!(len, length(v))
        end
    end

    oder = sortperm(len)
    key = keys[oder[1]]
    sval = vals[oder[1]]
    println("bord")
    printbord(bd)
    
    for val in copy(bd.bord_kouho[key])
        local kouho_backup =  copy(bd.bord_kouho)
        local bord_backup = copy(bd.bord)
        local cfback = bd.count_filled
        if !insert_and_propagete(bd, key, val)
            bd.bord_kouho = kouho_backup
            bd.bord = bord_backup
            bd.count_filled = cfback
            return continue
        end
        if bd.count_filled < 81
            search(bd)           
        else
            println("solution")
            printbord(bd)
            readline()
        end

        bd.bord_kouho = kouho_backup
        bd.bord = bord_backup
        bd.count_filled = cfback        
    end
    return true
  
end

function solve(prob, sol = "")
    bd = Bord(prob)
    search(bd)
end


prob = "004300209005009001070060043006002087190007400050083000600000105003508690042910300"
sol = "864371259325849761971265843436192587198657432257483916689734125713528694542916378"

prob2 = "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......"
prob2 = replace(prob2, "." => "0")

solve(prob2, sol)
