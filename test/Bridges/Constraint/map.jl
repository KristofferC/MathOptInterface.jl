using Test
using MathOptInterface
const MOI = MathOptInterface
const MOIB = MOI.Bridges

struct DummyBridge <: MOIB.Constraint.AbstractBridge
    id::Int
end

map = MOIB.Constraint.Map()
@test isempty(map)
@test !MOIB.Constraint.has_bridges(map)
x = MOI.VariableIndex(1)
y = MOI.VariableIndex(2)
fx = MOI.SingleVariable(x)
b1 = DummyBridge(1)
c1 = MOIB.Constraint.add_key_for_bridge(map, b1, fx, MOI.EqualTo(0.0))
@test c1.value == x.value
@test haskey(map, c1)
@test map[c1] == b1
@test MOIB.Constraint.number_of_type(map, typeof(c1)) == 1
@test collect(MOIB.Constraint.keys_of_type(map, typeof(c1))) == [c1]

@test length(map) == 1
@test !isempty(map)
@test MOIB.Constraint.has_bridges(map)

b2 = DummyBridge(2)
vov = MOI.VectorOfVariables([x, y])
c2 = MOIB.Constraint.add_key_for_bridge(map, b2, vov, MOI.SecondOrderCone(2))
@test c2.value == x.value
@test haskey(map, c2)
@test map[c2] == b2
@test MOIB.Constraint.number_of_type(map, typeof(c2)) == 1
@test collect(MOIB.Constraint.keys_of_type(map, typeof(c2))) == [c2]

@test length(map) == 2
@test !isempty(map)
@test MOIB.Constraint.has_bridges(map)

b3 = DummyBridge(3)
c3 = MOIB.Constraint.add_key_for_bridge(map, b3, 1.0fx + 2.0, MOI.EqualTo(0.0))
@test haskey(map, c3)
@test map[c3] == b3
@test MOIB.Constraint.number_of_type(map, typeof(c3)) == 1
@test collect(MOIB.Constraint.keys_of_type(map, typeof(c3))) == [c3]

@test length(map) == 3
@test !isempty(map)
@test MOIB.Constraint.has_bridges(map)

bridges = collect(values(map))
@test sort([b.id for b in bridges]) == 1:3
elements = sort(collect(map), by = el -> el.second.id)
@test elements[1].first == c1
@test elements[1].second == b1
@test elements[2].first == c2
@test elements[2].second == b2
@test elements[3].first == c3
@test elements[3].second == b3

@test MOIB.Constraint.list_of_key_types(map) == Set([
    (MOI.VectorOfVariables, MOI.SecondOrderCone),
    (MOI.SingleVariable, MOI.EqualTo{Float64}),
    (MOI.ScalarAffineFunction{Float64}, MOI.EqualTo{Float64})
])
@test MOIB.Constraint.variable_constraints(map, x) == [c1]
@test isempty(MOIB.Constraint.variable_constraints(map, y))

delete!(map, c1)
@test length(map) == 2
@test !isempty(map)
@test MOIB.Constraint.has_bridges(map)

@test MOIB.Constraint.list_of_key_types(map) == Set([
    (MOI.VectorOfVariables, MOI.SecondOrderCone),
    (MOI.ScalarAffineFunction{Float64}, MOI.EqualTo{Float64})
])
@test isempty(MOIB.Constraint.variable_constraints(map, x))
@test isempty(MOIB.Constraint.variable_constraints(map, y))
@test MOIB.Constraint.number_of_type(map, typeof(c1)) == 0
@test MOIB.Constraint.number_of_type(map, typeof(c2)) == 1
@test MOIB.Constraint.number_of_type(map, typeof(c3)) == 1

delete!(map, c2)
@test length(map) == 1
@test !isempty(map)
@test MOIB.Constraint.has_bridges(map)

@test MOIB.Constraint.list_of_key_types(map) == Set([
    (MOI.ScalarAffineFunction{Float64}, MOI.EqualTo{Float64})
])
@test MOIB.Constraint.number_of_type(map, typeof(c1)) == 0
@test MOIB.Constraint.number_of_type(map, typeof(c2)) == 0
@test MOIB.Constraint.number_of_type(map, typeof(c3)) == 1

delete!(map, c3)
@test length(map) == 0
@test isempty(map)
@test MOIB.Constraint.has_bridges(map)

@test isempty(MOIB.Constraint.list_of_key_types(map))
@test MOIB.Constraint.number_of_type(map, typeof(c1)) == 0
@test MOIB.Constraint.number_of_type(map, typeof(c2)) == 0
@test MOIB.Constraint.number_of_type(map, typeof(c3)) == 0
