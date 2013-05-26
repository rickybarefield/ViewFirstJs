define ["ViewFirstModel", "OneToMany", "ManyToOne"], (ViewFirstModel, OneToMany, ManyToOne) ->
  
  class ViewFirst
    @Model = ViewFirstModel
    @OneToMany = OneToMany
    @ManyToOne = ManyToOne
    
    
