node('any'){
  
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
               
               sh "docker info && docker version "
               }
     stage('Kubernetes'){
               kubectl apply -f 
               }
}
