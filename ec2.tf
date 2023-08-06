 # Creates EC2 SPOT Instance
resource "aws_spot_instance_request" "spot" { 
  count                      = var.SPOT_INSTANCE_COUNT

  ami                        = data.aws_ami.image.id
  instance_type              = var.SPOT_INSTANCE_TYPE
  vpc_security_group_ids     = [aws_security_group.allows_app.id]
  subnet_id                  = element(data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS, count.index)
  wait_for_fulfillment       = true
  
  # This creates requests to the request
  tags = {
    Name = "${var.COMPONENT}-${var.ENV}"
  }
}

# Creates On-demand Backend Component
resource "aws_instance" "od" {
  count                      = var.OD_INSTANCE_COUNT

  ami                        = data.aws_ami.image.id
  instance_type              = var.OD_INSTANCE_TYPE
  vpc_security_group_ids     = [aws_security_group.allows_app.id]
  subnet_id                  = element(data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS, count.index)
}

locals {
    INSTANCE_IDS             =  concat(aws_spot_instance_request.spot.*.spot_instance_id, aws_instance.od.*.id)
    INSTANCE_COUNT           =  var.OD_INSTANCE_COUNT + var.SPOT_INSTANCE_COUNT
    INSTANCE_IPS             =  concat(aws_spot_instance_request.spot.*.private_ip, aws_instance.od.*.private_ip)
}

# Creating tag and attaching it to the Instances 
resource "aws_ec2_tag" "tags" {
  count                     = local.INSTANCE_COUNT

  resource_id               = element(local.INSTANCE_IDS, count.index)
  key                       = "Name"
  value                     = "${var.COMPONENT}-${var.ENV}"
}