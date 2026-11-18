<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Home" />
<c:set var="activeNav" value="home" />
<%@ include file="/WEB-INF/views/_header.jspf" %>

<section class="hero">
    <div class="container">
        <h1>Tell us about your medical camp experience</h1>
        <p>Attended a health camp? Rate the doctors, medicines, cleanliness, staff and waiting time in under two
           minutes. Your honest feedback helps organisers fix problems and serve the next patient better.</p>
        <div class="actions">
            <a class="btn" href="${ctx}/feedback">Share your feedback</a>
            <a class="btn secondary" href="${ctx}/login">Organiser / admin login</a>
        </div>
    </div>
</section>

<div class="container">
    <section class="steps" aria-label="How it works">
        <div class="card step">
            <div class="num">1</div>
            <h3>Enter your details</h3>
            <p class="muted">Your name, age, contact number and the camp you visited.</p>
        </div>
        <div class="card step">
            <div class="num">2</div>
            <h3>Rate the services</h3>
            <p class="muted">Give 1 to 5 stars for doctor, medicines, cleanliness, staff and waiting time.</p>
        </div>
        <div class="card step">
            <div class="num">3</div>
            <h3>Suggest or complain</h3>
            <p class="muted">Tell organisers what worked and what needs to improve.</p>
        </div>
    </section>

    <section class="card sdg-box">
        <div class="sdg-badge" aria-hidden="true"><span><b>3</b>GOOD HEALTH</span></div>
        <div>
            <h2>Aligned with Sustainable Development Goal 3</h2>
            <p class="muted" style="margin:0">Replacing paper forms with an online portal saves time and lets camp
               organisers see, in real time, which services need attention, so healthcare quality keeps improving.</p>
        </div>
    </section>
</div>

<%@ include file="/WEB-INF/views/_footer.jspf" %>
