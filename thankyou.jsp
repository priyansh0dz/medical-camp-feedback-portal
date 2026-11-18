<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Thank you" />
<c:set var="activeNav" value="feedback" />
<%@ include file="/WEB-INF/views/_header.jspf" %>

<div class="container narrow">
    <div class="card thanks">
        <div class="tick" aria-hidden="true">&#10003;</div>
        <h1>Thank you for your feedback!</h1>
        <p class="muted">Your response (reference #<c:out value="${feedbackId}" />) has been recorded. The camp
           organisers will use it to improve the services at future camps.</p>
        <a class="btn" href="${ctx}/index.jsp">Back to home</a>
        <a class="btn secondary" href="${ctx}/feedback">Submit another response</a>
    </div>
</div>

<%@ include file="/WEB-INF/views/_footer.jspf" %>
