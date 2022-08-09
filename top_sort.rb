
def topsort(g)
  n = g.tsort_each_node.to_a.size
  v = Hash.new(false)
  ordering = Array.new(n).fill(0)
  i = n-1 #index for ordering array


  for at in g.tsort_each_node.to_a

    if v[at] == false
      visitedNodes = []
      dfs(at, v, visitedNodes, g)
      for nodeId in visitedNodes
        ordering[i] = nodeId
        i -= 1
      end
    end
  end
  ordering.reverse
end
def dfs(at, v, visitedNodes, g)
  v[at] = true
  g.tsort_each_child(at) do |to|
    if v[to] == false
      dfs(to, v, visitedNodes, g)
    end
  end
  visitedNodes.push(at)
end



