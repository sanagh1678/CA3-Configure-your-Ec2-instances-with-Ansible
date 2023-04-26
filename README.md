# CA3-Configure-your-Ec2-instances-with-Ansible
configure your Ec2 instances with Ansible CA3 
---
- name: start EC2 instance with a public IP address
  hosts: localhost
  connection: local
  gather_facts: no
  tasks:
    - name: Create EC2
      amazon.aws.ec2_instance:
        name: "ca3ansibleinstance"
        #key_name: "key-a"
        vpc_subnet_id: subnet-04e7e69c6762af8eb
        instance_type: t2.micro
        security_group: default
        region: us-east-1
        network:
          assign_public_ip: True
        image_id: ami-02396cdd13e9a1257
        state: started
        tags:
          Environment: Testing
