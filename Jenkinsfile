node('any'){
  
     stage('scm'){
            git branch: 'main', url: 'https://github.com/105636046/hello-java.git'
               }
     stage('build'){
            sh "mvn clean install"
               }
     stage('Sonar'){
               sh ""
               }
     stage('Docker'){
               sh "docker image build -t ."
               }
     stage('Kubernetes'){
               kubectl apply -f 
               }
}
