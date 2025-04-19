# Allocate Elastic IP for NAT Gateway in public subnet AZ1
resource "aws_eip" "eip1" {
  vpc = true

  tags = {
    Name = "${var.project_name}-${var.environment}-eip1"
  }
}

# Allocate Elastic IP for NAT Gateway in public subnet AZ2
resource "aws_eip" "eip2" {
  vpc = true

  tags = {
    Name = "${var.project_name}-${var.environment}-eip2"
  }
}

# Create NAT Gateway in public subnet AZ1
resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = var.public_subnet_az1_id

  tags = {
    Name = "${var.project_name}-${var.environment}-ng-az1"
  }

  # Ensure the NAT Gateway is created after the internet gateway
  depends_on = [var.internet_gateway]
}

# Create NAT Gateway in public subnet AZ2
resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = var.public_subnet_az2_id

  tags = {
    Name = "${var.project_name}-${var.environment}-ng-az2"
  }

  # Ensure the NAT Gateway is created after the internet gateway
  depends_on = [var.internet_gateway]
}

# Create private route table for AZ1 and add route through NAT Gateway AZ1
resource "aws_route_table" "private_route_table_az1" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az1.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt-az1"
  }
}

# Associate private app subnet AZ1 with private route table AZ1
resource "aws_route_table_association" "private_app_subnet_az1_rt_az1_association" {
  subnet_id      = var.private_app_subnet_az1_id
  route_table_id = aws_route_table.private_route_table_az1.id
}

# Associate private data subnet AZ1 with private route table AZ1
resource "aws_route_table_association" "private_data_subnet_az1_rt_az1_association" {
  subnet_id      = var.private_data_subnet_az1_id
  route_table_id = aws_route_table.private_route_table_az1.id
}

# Create private route table for AZ2 and add route through NAT Gateway AZ2
resource "aws_route_table" "private_route_table_az2" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az2.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt-az2"
  }
}

# Associate private app subnet AZ2 with private route table AZ2
resource "aws_route_table_association" "private_app_subnet_az2_rt_az2_association" {
  subnet_id      = var.private_app_subnet_az2_id
  route_table_id = aws_route_table.private_route_table_az2.id
}

# Associate private data subnet AZ2 with private route table AZ2
resource "aws_route_table_association" "private_data_subnet_az2_rt_az2_association" {
  subnet_id      = var.private_data_subnet_az2_id
  route_table_id = aws_route_table.private_route_table_az2.id
}
