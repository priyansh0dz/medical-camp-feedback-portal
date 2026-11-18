<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Admin login" />
<c:set var="activeNav" value="login" />
<%@ include file="/WEB-INF/views/_header.jspf" %>

<div class="container">
    <div class="card login-card">
        <h1 style="font-size:1.6rem">Admin login</h1>
        <p class="muted">Only camp organisers can view participant feedback.</p>

        <c:if test="${not empty error}">
            <div class="alert error" role="alert"><c:out value="${error}" /></div>
        </c:if>
        <c:if test="${param.loggedout == '1'}">
            <div class="alert success" role="status">You have been logged out.</div>
        </c:if>

        <form method="post" action="${ctx}/login" autocomplete="off">
            <input type="hidden" name="csrf" value="<c:out value='${csrf}'/>">
            <div class="field">
                <label class="lbl" for="username">Username</label>
                <input type="text" id="username" name="username" required maxlength="50" autofocus autocomplete="username">
            </div>
            <div class="field">
                <label class="lbl" for="password">Password</label>
                <input type="password" id="password" name="password" required autocomplete="current-password">
            </div>
            <button class="btn" type="submit" style="width:100%">Log in</button>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/views/_footer.jspf" %>
