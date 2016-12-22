#-------------------------------------------------------------------------------

var checkSubmodelExistence = func (ident)
{

   var i = -1;
   var checker = "";
   var found = false;

   while (i < 40 and checker != nil and !found)
   {
     i = i+1;
     checker = getprop (sprintf("/ai/models/ballistic[%i]/name",i));
     if (checker == ident)
      found = true;
   }

  if (found) return i;
  else return nil;

}

#-------------------------------------------------------------------------------
var submodelIsValid = func (number)
{
     return getprop (sprintf("/ai/models/ballistic[%i]/valid",number));
}

#-------------------------------------------------------------------------------
var attachSubmodel = func (ident)
{  
  if (ident == "" or ident == nil) return; #sanity check
  
  var submodel_index = checkSubmodelExistence (ident);
  
  if (submodel_index != nil) #the model has a node
  {
    if (submodelIsValid(submodel_index))
    {
     #the model is either there or flying somewhere, need to have it attached
     setprop (sprintf("/ai/models/ballistic[%i]/controls/slave-to-ac",submodel_index), true);
     setprop (sprintf("/ai/models/ballistic[%i]/controls/invisible",submodel_index), false);    
    }
    else
    {
     #the model is spent, reattach and trigger again
     setprop (sprintf("/ai/models/ballistic[%i]/controls/slave-to-ac",submodel_index), true);
     setprop (sprintf("/ai/models/ballistic[%i]/controls/invisible",submodel_index), false); 
     settimer (func{setprop (sprintf("/f-20/stores/%s/trigger", ident), true);},1.0);
    }
  }
  else #we need to create it
  {    
    setprop (sprintf("/f-20/stores/%s/trigger", ident), true);
  }
}

#-------------------------------------------------------------------------------
var removeSubmodel = func (ident)
{

  if (ident == "" or ident == nil) return; #sanity check
  
  var submodel_index = checkSubmodelExistence (ident);
  
  setprop (sprintf("/f-20/stores/%s/trigger", ident), false);
      
  if (submodel_index != nil)
  {
    setprop (sprintf("/ai/models/ballistic[%i]/controls/invisible",submodel_index), true);
    setprop (sprintf("/ai/models/ballistic[%i]/controls/slave-to-ac",submodel_index), true);
  }
  #else it is already not there
}

#-------------------------------------------------------------------------------
var dropSubmodel = func (ident)
{
  if (ident == "" or ident == nil) return; #sanity check  
  
  var submodel_index = checkSubmodelExistence (ident);
   
  if (submodel_index != nil)
   {
     setprop (sprintf("/ai/models/ballistic[%i]/controls/slave-to-ac",submodel_index), false);
     setprop (sprintf("/f-20/stores/%s/trigger", ident), false);
   }
   #else why drop something that is not there in the first place
}
