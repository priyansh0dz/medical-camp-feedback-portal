<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Something went wrong" />
<%@ include file="/WEB-INF/views/_header.jspf" %>

<div class="container narrow">
    <div class="card thanks">
        <h1>Oops, something went wrong</h1>
        <p class="muted">The page you asked for could not be shown. Please go back and try again.</p>
        <a class="btn" href="${ctx}/index.jsp">Back to home</a>
    </div>
</div>

<%@ include file="/WEB-INF/views/_footer.jspf" %>
