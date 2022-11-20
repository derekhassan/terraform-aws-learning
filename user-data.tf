data "template_file" "user_data" {
  template = file("./ec2_setup.yml")
}
