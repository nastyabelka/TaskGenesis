#!/bin/bash
PS3='Choose container to run: '
container=("Ansible" "Terraform" "Quit")
select im in "${container[@]}"; do
    case $im in
        "Ansible")
            docker run -it --rm \
            -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
            -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
            -v /Users/anastasiabelosickaa/Desktop/TaskGenesis/Ansible/Ans_roles:/data/a_roles \
            -v /Users/anastasiabelosickaa/Desktop/TaskGenesis/Ansible/for_ssh:/data/key_ssh \
            --name my-ansible-im \
            my_ansible_im:v1
            ;;
        "Terraform")
            docker run -it --rm \
            -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
            -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
            -v /Users/anastasiabelosickaa/Desktop/TaskGenesis/Terraform/templates:/data/ter_template \
            -v /Users/anastasiabelosickaa/Desktop/TaskGenesis/Terraform/for_ssh:/data/key_ssh \
            --name my_terraform_im \
            my_terraform_im:v1
            ;;
        "Quit")
            echo "User requested exit"
            exit
            ;;
            *) echo "invalid option $REPLY";;
    esac
done