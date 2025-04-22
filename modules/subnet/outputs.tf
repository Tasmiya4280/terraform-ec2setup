output "subnet" {
  value = aws_subnet.myapp-subnet-1.id 
}
output "myapp-rtb" {
  value = aws_route_table.myapp-route-table 
}