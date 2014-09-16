f1 = Face([1,2,3])
f2 = Face(1,2,3)
@test f1.v1 == f2.v1
@test f1.v2 == f2.v2
@test f1.v3 == f2.v3
