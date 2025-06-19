 terraform { 
  cloud { 
    
    organization = "Raman-Boora" 

    workspaces {     
      name = "Strapi-Deployment-ECS-workspace" 
    } 
  }  
}
 
