<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Give feedback" />
<c:set var="activeNav" value="feedback" />
<%@ include file="/WEB-INF/views/_header.jspf" %>

<%-- rating categories: field|label|question ; separated --%>
<c:set var="cats" value="ratingDoctor|Doctor consultation|How clear and attentive was the doctor?;ratingMedicine|Medicine availability|Were the medicines you needed available?;ratingCleanliness|Cleanliness and hygiene|Was the camp clean and hygienic?;ratingStaff|Staff behaviour|Were the staff and volunteers polite and helpful?;ratingWaiting|Waiting time|Was the waiting time reasonable?" />

<div class="container narrow">
    <h1>Medical camp feedback</h1>
    <p class="muted">Fields marked <span class="req">*</span> are required. Your details are only visible to camp organisers.</p>

    <c:if test="${not empty errors}">
        <div class="alert error" role="alert">
            <c:choose>
                <c:when test="${not empty errors.form}"><c:out value="${errors.form}" /></c:when>
                <c:otherwise>Please fix the highlighted fields and submit again.</c:otherwise>
            </c:choose>
        </div>
    </c:if>

    <form class="stack card" method="post" action="${ctx}/feedback" accept-charset="UTF-8">
        <input type="hidden" name="csrf" value="<c:out value='${csrf}'/>">

        <fieldset>
            <legend>1. About you</legend>
            <div class="grid">
                <div class="field full ${not empty errors.name ? 'has-error' : ''}">
                    <label class="lbl" for="name">Full name <span class="req">*</span></label>
                    <input type="text" id="name" name="name" maxlength="100" required value="<c:out value='${param.name}'/>" autocomplete="name">
                    <c:if test="${not empty errors.name}"><span class="err"><c:out value="${errors.name}" /></span></c:if>
                </div>

                <div class="field ${not empty errors.age ? 'has-error' : ''}">
                    <label class="lbl" for="age">Age <span class="req">*</span></label>
                    <input type="number" id="age" name="age" min="1" max="120" required value="<c:out value='${param.age}'/>">
                    <c:if test="${not empty errors.age}"><span class="err"><c:out value="${errors.age}" /></span></c:if>
                </div>

                <div class="field ${not empty errors.gender ? 'has-error' : ''}">
                    <span class="lbl" id="gender-lbl">Gender <span class="req">*</span></span>
                    <div class="radio-pills" role="radiogroup" aria-labelledby="gender-lbl">
                        <c:forEach var="g" items="${genders}">
                            <label><input type="radio" name="gender" value="${g}" required ${param.gender == g ? 'checked' : ''}><span><c:out value="${g}" /></span></label>
                        </c:forEach>
                    </div>
                    <c:if test="${not empty errors.gender}"><span class="err"><c:out value="${errors.gender}" /></span></c:if>
                </div>

                <div class="field ${not empty errors.phone ? 'has-error' : ''}">
                    <label class="lbl" for="phone">Phone number <span class="req">*</span></label>
                    <input type="tel" id="phone" name="phone" maxlength="18" required placeholder="e.g. 9876543210" value="<c:out value='${param.phone}'/>" autocomplete="tel">
                    <c:if test="${not empty errors.phone}"><span class="err"><c:out value="${errors.phone}" /></span></c:if>
                </div>

                <div class="field ${not empty errors.email ? 'has-error' : ''}">
                    <label class="lbl" for="email">Email (optional)</label>
                    <input type="email" id="email" name="email" maxlength="120" value="<c:out value='${param.email}'/>" autocomplete="email">
                    <c:if test="${not empty errors.email}"><span class="err"><c:out value="${errors.email}" /></span></c:if>
                </div>
            </div>
        </fieldset>

        <fieldset>
            <legend>2. Camp visited</legend>
            <div class="grid">
                <div class="field ${not empty errors.campName ? 'has-error' : ''}">
                    <label class="lbl" for="campName">Camp name / location <span class="req">*</span></label>
                    <input type="text" id="campName" name="campName" maxlength="120" required placeholder="e.g. Free Eye Camp, Shivamogga" value="<c:out value='${param.campName}'/>">
                    <c:if test="${not empty errors.campName}"><span class="err"><c:out value="${errors.campName}" /></span></c:if>
                </div>
                <div class="field ${not empty errors.visitDate ? 'has-error' : ''}">
                    <label class="lbl" for="visitDate">Date of visit <span class="req">*</span></label>
                    <input type="date" id="visitDate" name="visitDate" max="${today}" required value="<c:out value='${empty param.visitDate ? today : param.visitDate}'/>">
                    <c:if test="${not empty errors.visitDate}"><span class="err"><c:out value="${errors.visitDate}" /></span></c:if>
                </div>
            </div>
        </fieldset>

        <fieldset>
            <legend>3. Rate our services</legend>
            <div class="scale-note"><span>1 = Poor</span><span>5 = Excellent</span></div>
            <c:forEach var="row" items="${fn:split(cats, ';')}">
                <c:set var="parts" value="${fn:split(row, '|')}" />
                <c:set var="field" value="${parts[0]}" />
                <div class="rating-row">
                    <div class="what">
                        <strong><c:out value="${parts[1]}" /> <span class="req">*</span></strong>
                        <span><c:out value="${parts[2]}" /></span>
                        <c:if test="${not empty errors[field]}"><span class="err"><c:out value="${errors[field]}" /></span></c:if>
                    </div>
                    <div class="stars" role="radiogroup" aria-label="${parts[1]} rating">
                        <c:forEach var="v" items="5,4,3,2,1">
                            <input type="radio" id="${field}${v}" name="${field}" value="${v}" required ${param[field] == v ? 'checked' : ''}>
                            <label for="${field}${v}" title="${v} out of 5"><span aria-hidden="true">&#9733;</span><span class="sr">${v} out of 5</span></label>
                        </c:forEach>
                    </div>
                </div>
            </c:forEach>
        </fieldset>

        <fieldset>
            <legend>4. Suggestions or complaints</legend>
            <div class="grid">
                <div class="field full ${not empty errors.feedbackType ? 'has-error' : ''}">
                    <span class="lbl" id="type-lbl">Type of feedback <span class="req">*</span></span>
                    <div class="radio-pills" role="radiogroup" aria-labelledby="type-lbl">
                        <c:forEach var="t" items="${feedbackTypes}">
                            <label><input type="radio" name="feedbackType" value="${t}" required ${param.feedbackType == t ? 'checked' : ''}><span><c:out value="${t}" /></span></label>
                        </c:forEach>
                    </div>
                    <c:if test="${not empty errors.feedbackType}"><span class="err"><c:out value="${errors.feedbackType}" /></span></c:if>
                </div>
                <div class="field full ${not empty errors.comments ? 'has-error' : ''}">
                    <label class="lbl" for="comments">Your comments</label>
                    <textarea id="comments" name="comments" maxlength="1000" placeholder="What went well? What should be improved?"><c:out value="${param.comments}" /></textarea>
                    <span class="hint">Up to 1000 characters.</span>
                    <c:if test="${not empty errors.comments}"><span class="err"><c:out value="${errors.comments}" /></span></c:if>
                </div>
            </div>
        </fieldset>

        <button class="btn" type="submit">Submit feedback</button>
    </form>
</div>

<%@ include file="/WEB-INF/views/_footer.jspf" %>
