node(built-in node){
  
     stage(scm){
            git branch: 'main', url: 'https://github.com/105636046/hello-java.git'
               }
     stage(build){
            sh "maven clean package"
               }
     stage(Sonar){
               sh ""
               }
     stage(Docker){
               sh "docker image build -t ."
               }
     stage(Kubernetes){
               kubectl apply -f 
               }
}
