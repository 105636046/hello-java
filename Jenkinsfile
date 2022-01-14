node('any'){
  
     stage('scm'){
            git branch: 'main', url: 'https://github.com/105636046/hello-java.git'
               }
     stage('build'){
            sh "mvn package"
               }
     stage('Sonar'){
               sh ""
               }
     stage('Docker'){
               sh 'ls -al'
               sh 'cp ***/hello-world-1.0.0.jar  .'
               sh "docker image build -t ."
               }
     stage('Kubernetes'){
               kubectl apply -f 
               }
}
