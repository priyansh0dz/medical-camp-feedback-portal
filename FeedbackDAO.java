package com.medcamp.dao;

import com.medcamp.model.Feedback;
import com.medcamp.model.Stats;
import com.medcamp.util.DBUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/** All JDBC access for the feedback table. */
public class FeedbackDAO {

    private static final String AVG_EXPR =
            "(rating_doctor + rating_medicine + rating_cleanliness + rating_staff + rating_waiting) / 5.0";

    /** Search criteria used by the admin dashboard and CSV export. */
    public static class Filter {
        public String camp = "";
        public String type = "";
        /** "", "low" (&lt; 3), "mid" (3 to &lt; 4), "high" (&gt;= 4). */
        public String band = "";
        public String query = "";
    }

    public int insert(Feedback f) throws SQLException {
        String sql = "INSERT INTO feedback (participant_name, age, gender, phone, email, camp_name, visit_date, "
                + "rating_doctor, rating_medicine, rating_cleanliness, rating_staff, rating_waiting, "
                + "feedback_type, comments) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            int i = 1;
            ps.setString(i++, f.getParticipantName());
            ps.setInt(i++, f.getAge());
            ps.setString(i++, f.getGender());
            ps.setString(i++, f.getPhone());
            ps.setString(i++, f.getEmail());
            ps.setString(i++, f.getCampName());
            ps.setDate(i++, Date.valueOf(f.getVisitDate()));
            ps.setInt(i++, f.getRatingDoctor());
            ps.setInt(i++, f.getRatingMedicine());
            ps.setInt(i++, f.getRatingCleanliness());
            ps.setInt(i++, f.getRatingStaff());
            ps.setInt(i++, f.getRatingWaiting());
            ps.setString(i++, f.getFeedbackType());
            ps.setString(i, f.getComments());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    public List<Feedback> search(Filter filter, int limit, int offset) throws SQLException {
        List<Object> params = new ArrayList<>();
        String where = buildWhere(filter, params);
        String sql = "SELECT * FROM feedback" + where + " ORDER BY submitted_at DESC, id DESC LIMIT ? OFFSET ?";
        List<Feedback> list = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            int i = bind(ps, params);
            ps.setInt(i++, limit);
            ps.setInt(i, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    public int count(Filter filter) throws SQLException {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COUNT(*) FROM feedback" + buildWhere(filter, params);
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public Stats stats(Filter filter) throws SQLException {
        Stats s = new Stats();
        List<Object> params = new ArrayList<>();
        String where = buildWhere(filter, params);

        String avgSql = "SELECT COUNT(*), AVG(rating_doctor), AVG(rating_medicine), AVG(rating_cleanliness), "
                + "AVG(rating_staff), AVG(rating_waiting) FROM feedback" + where;
        try (Connection c = DBUtil.getConnection()) {
            try (PreparedStatement ps = c.prepareStatement(avgSql)) {
                bind(ps, params);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        s.setTotal(rs.getInt(1));
                        s.setAvgDoctor(rs.getDouble(2));
                        s.setAvgMedicine(rs.getDouble(3));
                        s.setAvgCleanliness(rs.getDouble(4));
                        s.setAvgStaff(rs.getDouble(5));
                        s.setAvgWaiting(rs.getDouble(6));
                    }
                }
            }

            for (int star = 1; star <= 5; star++) {
                s.getDistribution().put(star, 0);
            }
            String distSql = "SELECT LEAST(5, GREATEST(1, ROUND(" + AVG_EXPR + "))) AS bucket, COUNT(*) "
                    + "FROM feedback" + where + " GROUP BY bucket";
            try (PreparedStatement ps = c.prepareStatement(distSql)) {
                bind(ps, params);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        s.getDistribution().put(rs.getInt(1), rs.getInt(2));
                    }
                }
            }

            String typeSql = "SELECT feedback_type, COUNT(*) FROM feedback" + where
                    + " GROUP BY feedback_type ORDER BY COUNT(*) DESC";
            try (PreparedStatement ps = c.prepareStatement(typeSql)) {
                bind(ps, params);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        s.getByType().put(rs.getString(1), rs.getInt(2));
                    }
                }
            }
        }
        return s;
    }

    public List<String> campNames() throws SQLException {
        List<String> names = new ArrayList<>();
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT DISTINCT camp_name FROM feedback ORDER BY camp_name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                names.add(rs.getString(1));
            }
        }
        return names;
    }

    public boolean delete(int id) throws SQLException {
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement("DELETE FROM feedback WHERE id = ?")) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ---- helpers -------------------------------------------------------------------------

    private String buildWhere(Filter f, List<Object> params) {
        List<String> clauses = new ArrayList<>();
        if (f.camp != null && !f.camp.isEmpty()) {
            clauses.add("camp_name = ?");
            params.add(f.camp);
        }
        if (f.type != null && !f.type.isEmpty()) {
            clauses.add("feedback_type = ?");
            params.add(f.type);
        }
        if ("low".equals(f.band)) {
            clauses.add(AVG_EXPR + " < 3");
        } else if ("mid".equals(f.band)) {
            clauses.add(AVG_EXPR + " >= 3 AND " + AVG_EXPR + " < 4");
        } else if ("high".equals(f.band)) {
            clauses.add(AVG_EXPR + " >= 4");
        }
        if (f.query != null && !f.query.isEmpty()) {
            clauses.add("(participant_name LIKE ? OR phone LIKE ? OR comments LIKE ?)");
            String like = "%" + f.query.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        return clauses.isEmpty() ? "" : " WHERE " + String.join(" AND ", clauses);
    }

    private int bind(PreparedStatement ps, List<Object> params) throws SQLException {
        int i = 1;
        for (Object p : params) {
            ps.setObject(i++, p);
        }
        return i;
    }

    private Feedback map(ResultSet rs) throws SQLException {
        Feedback f = new Feedback();
        f.setId(rs.getInt("id"));
        f.setParticipantName(rs.getString("participant_name"));
        f.setAge(rs.getInt("age"));
        f.setGender(rs.getString("gender"));
        f.setPhone(rs.getString("phone"));
        f.setEmail(rs.getString("email"));
        f.setCampName(rs.getString("camp_name"));
        f.setVisitDate(rs.getDate("visit_date").toLocalDate());
        f.setRatingDoctor(rs.getInt("rating_doctor"));
        f.setRatingMedicine(rs.getInt("rating_medicine"));
        f.setRatingCleanliness(rs.getInt("rating_cleanliness"));
        f.setRatingStaff(rs.getInt("rating_staff"));
        f.setRatingWaiting(rs.getInt("rating_waiting"));
        f.setFeedbackType(rs.getString("feedback_type"));
        f.setComments(rs.getString("comments"));
        f.setSubmittedAt(rs.getTimestamp("submitted_at"));
        return f;
    }
}
