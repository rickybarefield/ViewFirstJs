define ["ViewFirstModel", "BindHelpers", "OneToMany", "ManyToOne"], (ViewFirstModel, BindHelpers, OneToMany, ManyToOne) ->
  
  class ViewFirst extends BindHelpers
    @Model = ViewFirstModel
    @OneToMany = OneToMany
    @ManyToOne = ManyToOne
    
    
