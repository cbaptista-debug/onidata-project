resource "aws_api_gateway_rest_api" "api" {
 name = "api-gateway"
 deion = "Proxy to handle requests to our API"
}

resource "aws_api_gateway_authorizer" "cognito-customer-authorizer" {
  name                   = "CognitoCustomerPoolAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  type = "COGNITO_USER_POOLS"

  provider_arns = [
    module.cognito-pool.cognito-customer-pool-arn
  ]
}

resource "aws_api_gateway_vpc_link" "test" {
  name        = "VPC_LINK" 
  deion = "Provides access to app" 
  target_arns = ["arn:aws:elasticloadbalancing:us-east-1:133876145150:loadbalancer/net/4454b6fdbdbbfdbbdf81c27aae/54de6dc46ngfnf1d940a0"] 
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito-customer-authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://onidata.com/{proxy}" 
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.test.id
 
  request_parameters =  {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "instance" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "prod"

  variables = {
    deployed_at = "${timestamp()}"
  }
}

# Domain

#resource "aws_api_gateway_domain_name" "domain" {
#  certificate_arn = "arn:aws:acm:us-east-1:453453453453:certificate/453453543453-adc1-4b77-453245345345-8c345345345631b"
#  domain_name = "kiq.pkds.it"
#}
#resource "aws_api_gateway_base_path_mapping" "base_path_mapping" {
#  api_id      = "${aws_api_gateway_rest_api.api.id}"
#  
#  domain_name = "${aws_api_gateway_domain_name.domain.domain_name}"
#}

##https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api
##Doc ref https://medium.com/onfido-tech/aws-api-gateway-with-terraform-7a2bebe8b68f
##Doc rewf http://man.hubwiz.com/docset/Terraform.docset/Contents/Resources/Documents/docs/providers/aws/r/api_gateway_vpc_link.html
## 