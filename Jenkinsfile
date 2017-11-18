node {
    def app

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout scm
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */

        app = docker.build("aslaen/opencamp2017", "-f app/dockerfile app/.")
    }

    stage('Test image') {
        /* Ideally, we would run a test framework against our image.
         * For this example, we're using a Volkswagen-type approach ;-) */

        app.inside {
            sh 'echo "Tests passed"'
        }
    }

    stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */
        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }

    stage("Create AWS Infrastructure") {
        /* Using Terraform to create AWS infra */
        withAWS(credentials:'aws-creds') {
            sh "echo Creating AWS Infrastructure"
            sh "terraform init"
            sh "terraform apply -auto-approve"
            sh "echo sleeping to allow startup"
            sh "sleep 1m"

    }
}
    stage("Install Ansible requirements") {
        /* Install Python required for Ansible */
        ansiblePlaybook( 
        playbook: 'setup.yml',
        inventory: 'kubespray/inventory/inventory', 
        extras: '--private-key /var/jenkins_home/.ssh/ansible -b -u ubuntu') 
    }
    stage("Install Kubespray dependencies") {
        sh "pip install -r https://raw.githubusercontent.com/kubernetes-incubator/kubespray/master/requirements.txt"
    }
    stage("Deploy Kubernetes") {
        /* Now let's deploy Kubernetes */
        ansiblePlaybook( 
        playbook: 'kubespray/cluster.yml',
        inventory: 'kubespray/inventory/inventory', 
        extras: '--private-key /var/jenkins_home/.ssh/ansible -b -u ubuntu')
}
    stage("Deploy app on Kubernetes") {
        /* Deploy app we built from dockerfile onto our Kubernetes cluster*/
        ansiblePlaybook(
        playbook: 'deploy_node.yml',
        inventory: 'kubespray/inventory/inventory',
        extras: '--private-key /var/jenkins_home/.ssh/ansible -u ubuntu')
    }
}
