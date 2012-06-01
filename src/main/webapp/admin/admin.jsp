<%@page import="edu.ucsf.mousedatabase.*" %>
<%@page import="edu.ucsf.mousedatabase.objects.*" %>
<%@page import="java.util.ArrayList" %>
<%=HTMLGeneration.getPageHeader(null,false,true) %>
<%=HTMLGeneration.getNavBar("admin.jsp", true) %>


<%

  ArrayList<ArrayList<SubmittedMouse>> submissionLists = new ArrayList<ArrayList<SubmittedMouse>>();
  submissionLists.add(DBConnect.getMouseSubmissions("new",null,null));
  submissionLists.add(DBConnect.getMouseSubmissions("need more info",null,null));
  String[] submissionListLabels = new String[]{"new submissions","submissions on hold"};


  ArrayList<ArrayList<ChangeRequest>> changeRequestLists = new ArrayList<ArrayList<ChangeRequest>>();
  changeRequestLists.add(DBConnect.getChangeRequests("new", null));
  changeRequestLists.add( DBConnect.getChangeRequests("pending",null)) ;
  String[] changeRequestListLabels = new String[]{"new","pending"};

  StringBuffer buf = new StringBuffer();
  for(int i =0; i< submissionLists.size(); i++)
  {
    ArrayList<SubmittedMouse> newSubmissions = submissionLists.get(i);
    String label = submissionListLabels[i];
    if(newSubmissions.size() > 0)
    {

      buf.append("<dl>");
      buf.append("<dt><font color='green'><b>There are " + newSubmissions.size() + " " + label + "!</b></font></dt>");
      for(SubmittedMouse mouse : newSubmissions)
      {
        String mouseName = "";
        if (mouse.getOfficialSymbol() == null || mouse.getOfficialSymbol().isEmpty())
        {
          mouseName = mouse.getMouseName();
          if(mouseName == null || mouseName.isEmpty())
          {
            mouseName = mouse.getOfficialMouseName();
          }
        }
        String action = "held by";
        if (mouse.getProperties().containsKey(SubmittedMouse.SubmissionSourceKey))
        {
          String submissionSource = mouse.getProperties().getProperty(SubmittedMouse.SubmissionSourceKey);
          if (submissionSource.equals(SubmittedMouse.PurchaseImport))
          {
            action = "purchased by";
          }
          else if (submissionSource.equals(SubmittedMouse.OtherInstitutionImport)){
           action = "imported by";
          }

        }
        String holders = "";
        ArrayList<MouseHolder> mouseHolders = mouse.getHolders();
        if (mouse.getHolderName() != null && !mouse.getHolderName().equals("unassigned"))
        {
          holders += mouse.getHolderName();
        }
        if (mouseHolders != null)
        {
          for (MouseHolder holder : mouseHolders)
          {
            if (holders.length() > 0) holders += ", ";
            holders += holder.getFullname();
          }
        }
        buf.append("<dd><span class='mouseName'>" + mouseName
            + HTMLUtilities.getCommentForDisplay(HTMLGeneration.emptyIfNull(mouse.getOfficialSymbol()))
            + "</span> " + action + "  " + holders
            + " - <a href=\"CreateNewRecord.jsp?id=" + mouse.getSubmissionID() + "\">Convert to record</a></dd>");
      }
      buf.append("</dl>");
    }
  }


  for (int i = 0; i < changeRequestLists.size();i++)
  {
    ArrayList<ChangeRequest> changeRequests = changeRequestLists.get(i);
    String label = changeRequestListLabels[i];
    if(changeRequests.size() > 0)
    {
      buf.append("<dl>");
      buf.append("<dt><font color='green'><b>There are " + changeRequests.size() + " " + label + " change requests!</b></font></dt>");
      for(ChangeRequest changeRequest : changeRequests)
      {
        String userComment = changeRequest.getUserComment();
        String adminComment = changeRequest.getAdminComment();
        String changeRequestTitle = changeRequest.getFirstname() + " " + changeRequest.getLastname();
        try{
        int index = -1;

        if ((index = userComment.indexOf("ADD HOLDER: ")) >= 0)
        {
          int parenIndex = userComment.indexOf("(");
          if (parenIndex > 0)
          {
            changeRequestTitle = "Add holder: " + userComment.substring(11 + index,parenIndex);
          }
        }
        else if ((index = userComment.indexOf("DELETE HOLDER: ")) >= 0)
        {
          int parenIndex = userComment.indexOf("(");
          if (parenIndex > 0)
          {
            changeRequestTitle = "Remove holder: " + userComment.substring(14 + index,parenIndex);
          }
        }
        else if  (changeRequest.Properties().containsKey("Add Holder"))
        {
          String holderData = changeRequest.Properties().getProperty("Add Holder");
          index = holderData.indexOf('|');
          if (index >=0)
          {
            holderData = holderData.substring(index+1);
          }
          changeRequestTitle = "Add holder: " + holderData;

        }
        }catch(Exception e)
        {

        }

        ArrayList<MouseRecord> mouse = DBConnect.getMouseRecord(changeRequest.getMouseID());
        if(mouse.size() > 0)
        {
          buf.append("<dd>" + changeRequestTitle
              +  ": <span class='mouseName'>" + HTMLGeneration.emptyIfNull(mouse.get(0).getMouseName()) + "</span> "
              + "<a href=\"CompleteChangeRequest.jsp?id="
              + changeRequest.getRequestID() + "\">Edit record #"
              + changeRequest.getMouseID() + "</a>");
        }
      }
      buf.append("</dl>");
    }
  }


%>
<div class="pagecontent">
<h2>Welcome to Mouse Inventory Administration.</h2>
Administer the Mouse Inventory by choosing from the menu items above.

<%=buf.toString() %>
</div>
