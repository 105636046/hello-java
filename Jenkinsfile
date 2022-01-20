node('any'){
 properties([parameters([string(defaultValue: 'dev', name: 'BRANCH_NAME'), choice(choices: ['dev'], name: 'BRANCH_NAME'), choice(choices: ['int'], name: 'BRANCH_NAME'), choice(choices: ['prod'], name: 'BRANCH_NAME')])])
  
     stage('scm'){
            git branch: 'main', url: 'https://github.com/105636046/hello-java.git'
               }
     stage('build'){
            sh "mvn package"
               }
     stage('Sonar'){
               sh "curl -fsSL https://get.docker.com -o get-docker.sh"
               }
     stage('Docker'){
               sh "curl -fsSL https://get.docker.com -o get-docker.sh"
               sh 'sudo sh get-docker.sh'
               sh 'sudo usermod -aG docker $USER'
               sh 'sudo chown "$USER":"$USER" /home/"$USER"/.docker -R && sudo chmod g+rwx "$HOME/.docker" -R'
               sh 'sudo systemctl enable docker.service && sudo systemctl enable containerd.service'
               sh "docker info && docker version "
               }
     stage('Kubernetes'){
               kubectl apply -f 
               }
}
