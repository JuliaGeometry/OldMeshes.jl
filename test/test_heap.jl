using DataStructures

immutable Node
    id   :: Int
    cost :: Float64
    Node(i,c) = new(i,c)    
end
<(n1::Node,n2::Node) = n1.cost < n2.cost

heap = mutable_binary_minheap(Node)
heapKeys = Dict{Int,Int}()

# add a bunch of numbers
nAdd = 10000
for j = 1:nAdd
    i = rand(Int)
    c = rand(Float64)
    k = push!(heap,Node(i,c))
    push!(heapKeys,i,k)
end

# pop a number and update a few until empty
while !isempty(heap)
    n = pop!(heap)
    delete!(heapKeys,n.id)

    if !isempty(heap)
        ids = collect(keys(heapKeys))
        len = length(ids)
        for j = 1:3
            i = ids[rand(1:len)]
            k = heapKeys[i]
            c = rand(Float64)
            update!(heap,k,Node(i,c))
        end
    end
end


println(heap)
println(keys)
