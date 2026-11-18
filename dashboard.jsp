<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Admin dashboard" />
<c:set var="activeNav" value="dashboard" />
<%@ include file="/WEB-INF/views/_header.jspf" %>

<div class="container">
    <div class="dash-head">
        <div>
            <h1 style="font-size:1.8rem">Feedback dashboard</h1>
            <p class="muted" style="margin:0">Signed in as <strong><c:out value="${adminUser}" /></strong></p>
        </div>
        <div>
            <a class="btn secondary small" href="${ctx}/admin/export?${queryString}">Download CSV</a>
            <button class="btn secondary small" type="button" onclick="window.print()">Print</button>
        </div>
    </div>

    <c:if test="${not empty dbError}">
        <div class="alert error" role="alert"><c:out value="${dbError}" /> Check the database settings and try again.</div>
    </c:if>

    <c:if test="${empty dbError}">

    <%-- ---- Summary numbers ---- --%>
    <div class="stat-grid">
        <div class="stat">
            <div class="label">Responses<c:if test="${not empty queryString}"> (filtered)</c:if></div>
            <div class="value">${stats.total}</div>
        </div>
        <div class="stat">
            <div class="label">Overall rating</div>
            <div class="value">
                <c:choose>
                    <c:when test="${stats.total > 0}"><fmt:formatNumber value="${stats.overallAverage}" pattern="0.0" /> <small>/ 5</small></c:when>
                    <c:otherwise>&ndash;</c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="stat">
            <div class="label">Complaints</div>
            <div class="value">${empty stats.byType['Complaint'] ? 0 : stats.byType['Complaint']}</div>
        </div>
        <div class="stat">
            <div class="label">Suggestions</div>
            <div class="value">${empty stats.byType['Suggestion'] ? 0 : stats.byType['Suggestion']}</div>
        </div>
    </div>

    <div class="two-col">
        <%-- ---- Average per service ---- --%>
        <section class="card" aria-labelledby="avg-h">
            <h2 id="avg-h">Average rating by service</h2>
            <c:choose>
                <c:when test="${stats.total == 0}"><p class="empty">No feedback yet.</p></c:when>
                <c:otherwise>
                    <c:forEach var="e" items="${stats.categoryAverages}">
                        <div class="bar-row">
                            <span><c:out value="${e.key}" /></span>
                            <div class="bar-track" role="img" aria-label="${e.key}: <fmt:formatNumber value='${e.value}' pattern='0.0'/> out of 5">
                                <div class="bar-fill ${e.value < 3 ? 'low' : (e.value < 3.5 ? 'mid' : '')}" style="width:<fmt:formatNumber value='${e.value * 20}' pattern='0.#' />%"></div>
                            </div>
                            <span class="num"><fmt:formatNumber value="${e.value}" pattern="0.0" /></span>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </section>

        <%-- ---- Areas needing improvement ---- --%>
        <section class="card" aria-labelledby="imp-h">
            <h2 id="imp-h">Areas needing improvement</h2>
            <c:choose>
                <c:when test="${stats.total == 0}"><p class="empty">Waiting for the first response.</p></c:when>
                <c:when test="${empty stats.improvementAreas}">
                    <p class="allgood">All services average 3.5 or higher. Keep it up!</p>
                </c:when>
                <c:otherwise>
                    <p class="muted small">Services averaging below 3.5 out of 5, lowest first:</p>
                    <ul class="improve">
                        <c:forEach var="e" items="${stats.improvementAreas}">
                            <li class="${e.value < 3 ? 'critical' : ''}">
                                <span><c:out value="${e.key}" /></span>
                                <strong><fmt:formatNumber value="${e.value}" pattern="0.0" /> / 5</strong>
                            </li>
                        </c:forEach>
                    </ul>
                </c:otherwise>
            </c:choose>
        </section>
    </div>

    <%-- ---- Rating distribution ---- --%>
    <section class="card" aria-labelledby="dist-h" style="margin-bottom:1.25rem">
        <h2 id="dist-h">Overall rating distribution</h2>
        <c:forEach var="d" items="${stats.distributionDescending}">
            <div class="bar-row">
                <span>${d.key} star<c:if test="${d.key != 1}">s</c:if></span>
                <div class="bar-track">
                    <div class="bar-fill neutral" style="width:<fmt:formatNumber value='${stats.total == 0 ? 0 : d.value * 100.0 / stats.total}' pattern='0.#' />%"></div>
                </div>
                <span class="num">${d.value}</span>
            </div>
        </c:forEach>
    </section>

    <%-- ---- Filters + table ---- --%>
    <section class="card" aria-labelledby="list-h">
        <h2 id="list-h">All feedback</h2>

        <form class="filters" method="get" action="${ctx}/admin/dashboard">
            <div>
                <label class="lbl" for="q">Search</label>
                <input type="search" id="q" name="q" maxlength="100" placeholder="Name, phone or comment" value="<c:out value='${filter.query}'/>">
            </div>
            <div>
                <label class="lbl" for="camp">Camp</label>
                <select id="camp" name="camp">
                    <option value="">All camps</option>
                    <c:forEach var="campName" items="${camps}">
                        <option value="<c:out value='${campName}'/>" ${filter.camp == campName ? 'selected' : ''}><c:out value="${campName}" /></option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="lbl" for="type">Type</label>
                <select id="type" name="type">
                    <option value="">All types</option>
                    <c:forEach var="t" items="${types}">
                        <option value="${t}" ${filter.type == t ? 'selected' : ''}>${t}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="lbl" for="band">Rating</label>
                <select id="band" name="band">
                    <option value="">Any</option>
                    <option value="low" ${filter.band == 'low' ? 'selected' : ''}>Below 3</option>
                    <option value="mid" ${filter.band == 'mid' ? 'selected' : ''}>3 to 3.9</option>
                    <option value="high" ${filter.band == 'high' ? 'selected' : ''}>4 and above</option>
                </select>
            </div>
            <div class="actions">
                <button class="btn small" type="submit">Apply</button>
                <a class="btn secondary small" href="${ctx}/admin/dashboard">Reset</a>
            </div>
        </form>

        <p class="muted small" style="margin:.9rem 0 0">Showing page ${page} of ${totalPages} &middot; ${total} matching response<c:if test="${total != 1}">s</c:if></p>

        <c:choose>
            <c:when test="${empty feedbackList}">
                <p class="empty">No feedback matches these filters.</p>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table class="data">
                        <thead>
                            <tr>
                                <th scope="col">#</th>
                                <th scope="col">Participant</th>
                                <th scope="col">Camp / visit</th>
                                <th scope="col" title="Doctor, Medicine, Cleanliness, Staff, Waiting">Ratings (D M C S W)</th>
                                <th scope="col">Avg</th>
                                <th scope="col">Type</th>
                                <th scope="col">Comments</th>
                                <th scope="col"><span class="sr">Actions</span></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="f" items="${feedbackList}">
                                <tr>
                                    <td>${f.id}<br><span class="muted small"><fmt:formatDate value="${f.submittedAt}" pattern="dd MMM yyyy" /></span></td>
                                    <td>
                                        <strong><c:out value="${f.participantName}" /></strong><br>
                                        <span class="muted small"><c:out value="${f.age}" />, <c:out value="${f.gender}" /></span><br>
                                        <span class="small"><c:out value="${f.phone}" /></span>
                                        <c:if test="${not empty f.email}"><br><span class="small"><c:out value="${f.email}" /></span></c:if>
                                    </td>
                                    <td><c:out value="${f.campName}" /><br><span class="muted small">Visited ${f.visitDate}</span></td>
                                    <td>
                                        <div class="chips">
                                            <span class="chip r${f.ratingDoctor}" title="Doctor">${f.ratingDoctor}</span>
                                            <span class="chip r${f.ratingMedicine}" title="Medicine">${f.ratingMedicine}</span>
                                            <span class="chip r${f.ratingCleanliness}" title="Cleanliness">${f.ratingCleanliness}</span>
                                            <span class="chip r${f.ratingStaff}" title="Staff">${f.ratingStaff}</span>
                                            <span class="chip r${f.ratingWaiting}" title="Waiting time">${f.ratingWaiting}</span>
                                        </div>
                                    </td>
                                    <td class="avg"><fmt:formatNumber value="${f.averageRating}" pattern="0.0" /></td>
                                    <td><span class="badge ${fn:toLowerCase(f.feedbackType)}"><c:out value="${f.feedbackType}" /></span></td>
                                    <td class="comment"><c:out value="${f.comments}" /></td>
                                    <td>
                                        <form method="post" action="${ctx}/admin/delete" onsubmit="return confirm('Delete feedback #${f.id} permanently?');">
                                            <input type="hidden" name="csrf" value="<c:out value='${csrf}'/>">
                                            <input type="hidden" name="id" value="${f.id}">
                                            <input type="hidden" name="back" value="<c:out value='${queryString}'/><c:if test="${not empty queryString}">&amp;</c:if>page=${page}">
                                            <button class="btn danger" type="submit">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <c:if test="${totalPages > 1}">
                    <nav class="pager" aria-label="Pagination">
                        <c:if test="${page > 1}">
                            <a href="${ctx}/admin/dashboard?${queryString}<c:if test='${not empty queryString}'>&amp;</c:if>page=${page - 1}">&laquo; Prev</a>
                        </c:if>
                        <c:forEach var="p" begin="1" end="${totalPages}">
                            <c:choose>
                                <c:when test="${p == page}"><span class="current" aria-current="page">${p}</span></c:when>
                                <c:when test="${p == 1 || p == totalPages || (p >= page - 2 && p <= page + 2)}">
                                    <a href="${ctx}/admin/dashboard?${queryString}<c:if test='${not empty queryString}'>&amp;</c:if>page=${p}">${p}</a>
                                </c:when>
                                <c:when test="${p == page - 3 || p == page + 3}"><span class="gap">&hellip;</span></c:when>
                            </c:choose>
                        </c:forEach>
                        <c:if test="${page < totalPages}">
                            <a href="${ctx}/admin/dashboard?${queryString}<c:if test='${not empty queryString}'>&amp;</c:if>page=${page + 1}">Next &raquo;</a>
                        </c:if>
                    </nav>
                </c:if>
            </c:otherwise>
        </c:choose>
    </section>

    </c:if>
</div>

<%@ include file="/WEB-INF/views/_footer.jspf" %>
