/*
 Navicat Premium Dump SQL

 Source Server         : 本地mysql
 Source Server Type    : MySQL
 Source Server Version : 80407 (8.4.7)
 Source Host           : localhost:3306
 Source Schema         : cl

 Target Server Type    : MySQL
 Target Server Version : 80407 (8.4.7)
 File Encoding         : 65001

<<<<<<< HEAD
 Date: 17/07/2026 14:29:54
=======
 Date: 17/07/2026 14:00:35
>>>>>>> 9ddca126966f1b1d88318a99a242719f22925f14
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for careers
-- ----------------------------
DROP TABLE IF EXISTS `careers`;
CREATE TABLE `careers`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` enum('active','coming_soon') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'coming_soon',
  `theme_color` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '#00d4ff',
  `total_scenes` tinyint NULL DEFAULT 0,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
<<<<<<< HEAD
  `growth_path` json NULL,
=======
>>>>>>> 9ddca126966f1b1d88318a99a242719f22925f14
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 51 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of careers
-- ----------------------------
<<<<<<< HEAD
INSERT INTO `careers` VALUES (5, '后端开发工程师', '🖥️', '负责服务器端逻辑、API接口开发、数据库设计与优化，是互联网系统的核心支撑', 'active', '#00d4ff', 5, '2026-07-16 19:41:49', '[{\"desc\": \"掌握基础技能，独立完成日常任务\", \"level\": \"初级\"}, {\"desc\": \"独当一面，解决复杂问题\", \"level\": \"中级\"}, {\"desc\": \"技术引领，团队指导与架构设计\", \"level\": \"高级\"}, {\"desc\": \"行业影响，技术战略制定\", \"level\": \"专家/架构师\"}]');
INSERT INTO `careers` VALUES (6, '前端开发工程师', '🎨', '负责网页/APP界面交互、用户体验优化，让产品好看又好用', 'coming_soon', '#ff6b6b', 0, '2026-07-16 19:41:49', '[{\"desc\": \"掌握基础技能，独立完成日常任务\", \"level\": \"初级\"}, {\"desc\": \"独当一面，解决复杂问题\", \"level\": \"中级\"}, {\"desc\": \"技术引领，团队指导与架构设计\", \"level\": \"高级\"}, {\"desc\": \"行业影响，技术战略制定\", \"level\": \"专家/架构师\"}]');
INSERT INTO `careers` VALUES (7, '运维/DevOps工程师', '⚙️', '负责系统部署、监控告警、性能调优，保障服务稳定运行', 'coming_soon', '#ffd93d', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (8, '数据分析师', '📊', '负责数据采集、清洗、建模和可视化，用数据驱动业务决策', 'coming_soon', '#6bcb77', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (9, 'AI/机器学习工程师', '🤖', '负责构建智能算法模型，推动人工智能在业务场景中落地', 'coming_soon', '#a66cff', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (10, '网络安全工程师', '🔒', '负责系统安全防护、漏洞挖掘与修复，守护数字资产安全', 'coming_soon', '#ff6b6b', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (11, '移动开发工程师', '📱', '负责iOS/Android端APP开发与维护，打造流畅的移动体验', 'coming_soon', '#4ecdc4', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (12, '云计算架构师', '☁️', '负责云平台架构设计与优化，构建高可用、可扩展的云原生系统', 'coming_soon', '#00b4d8', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (13, '区块链开发工程师', '⛓️', '负责区块链底层技术研发与智能合约开发，推动去中心化应用落地', 'coming_soon', '#f77f00', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (14, '银行客户经理', '🏦', '负责银行客户关系维护、金融产品推荐与销售，提供综合金融服务方案', 'coming_soon', '#003366', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (15, '证券分析师', '📈', '负责证券市场研究、投资策略分析与报告撰写，为投资者提供决策依据', 'coming_soon', '#1a5276', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (16, '保险精算师', '📋', '负责保险产品费率测算、风险评估与准备金评估，是保险公司的核心岗位', 'coming_soon', '#2e4053', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (17, '投资银行家', '💰', '负责企业融资、并购重组、上市辅导等资本市场业务', 'coming_soon', '#1a2a4a', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (18, '财务分析师', '📉', '负责企业财务数据分析、预算编制与经营决策支持', 'coming_soon', '#2c3e50', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (19, '风控经理', '🛡️', '负责金融风险识别、评估与控制，确保业务合规与资产安全', 'coming_soon', '#e74c3c', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (20, '临床医生', '👨‍⚕️', '负责疾病诊断、治疗方案制定与患者管理，守护生命健康', 'coming_soon', '#2e86c1', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (21, '护理师', '👩‍⚕️', '负责患者护理、健康监测与医疗辅助，是医疗团队的重要成员', 'coming_soon', '#5dade2', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (22, '药剂师', '💊', '负责药品配发、用药指导与药物管理，保障患者用药安全', 'coming_soon', '#27ae60', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (23, '公共卫生专家', '🌍', '负责疾病预防、健康教育与公共卫生政策制定与实施', 'coming_soon', '#1a8c4a', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (24, '医疗影像技师', '🩻', '负责CT、MRI、X光等医学影像设备操作与图像采集', 'coming_soon', '#3498db', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (25, '教师', '📚', '负责课程教学、学生辅导与教育研究，培养未来人才', 'coming_soon', '#e67e22', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (26, '教育管理专家', '🏫', '负责学校运营管理、教育政策制定与教育资源统筹', 'coming_soon', '#d4ac0d', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (27, '教育技术专家', '💻', '负责在线教育平台研发、教育产品设计与教育信息化建设', 'coming_soon', '#2ecc71', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (28, '课程设计师', '📝', '负责课程体系设计、教学资源开发与学习体验优化', 'coming_soon', '#f39c12', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (29, '律师', '⚖️', '负责法律咨询、案件代理与法律文书撰写，维护当事人合法权益', 'coming_soon', '#8e44ad', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (30, '法务专员', '📄', '负责企业合同审核、合规管理与法律风险防控', 'coming_soon', '#9b59b6', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (31, '知识产权专员', '📜', '负责专利、商标、版权等知识产权申请与保护工作', 'coming_soon', '#6c3483', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (32, '平面设计师', '🎨', '负责品牌视觉设计、广告创意与平面物料制作', 'coming_soon', '#e84393', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (33, 'UI/UX设计师', '🖌️', '负责产品界面设计与用户体验优化，提升产品易用性', 'coming_soon', '#fd79a8', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (34, '插画师', '✏️', '负责商业插画、绘本创作与视觉艺术表达', 'coming_soon', '#fdcb6e', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (35, '动画师', '🎬', '负责2D/3D动画制作、特效设计与影视后期合成', 'coming_soon', '#e17055', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (36, '品牌经理', '🏷️', '负责品牌战略规划、市场定位与品牌价值提升', 'coming_soon', '#0984e3', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (37, '数字营销专家', '📱', '负责SEO/SEM、社交媒体运营与数字广告投放，提升品牌影响力', 'coming_soon', '#00b894', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (38, '市场分析师', '📊', '负责市场调研、竞品分析与消费者洞察，为决策提供数据支持', 'coming_soon', '#00cec9', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (39, '土木工程师', '🏗️', '负责建筑工程设计、施工管理与结构安全评估', 'coming_soon', '#d35400', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (40, '电气工程师', '⚡', '负责电力系统设计、电气设备选型与自动化控制', 'coming_soon', '#f39c12', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (41, '机械工程师', '🔧', '负责机械设备设计、制造工艺优化与生产管理', 'coming_soon', '#7f8c8d', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (42, '建筑设计师', '🏛️', '负责建筑方案设计、空间规划与建筑美学表达', 'coming_soon', '#a0522d', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (43, '新闻记者', '🎤', '负责新闻采访、报道与内容采编，传递真实、客观的新闻资讯', 'coming_soon', '#2c3e50', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (44, '新媒体运营', '📱', '负责新媒体内容策划、用户运营与品牌传播', 'coming_soon', '#e74c3c', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (45, '视频编导', '🎥', '负责视频内容策划、拍摄执导与后期制作统筹', 'coming_soon', '#f39c12', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (46, '酒店经理', '🏨', '负责酒店运营管理、客户服务与团队建设', 'coming_soon', '#34495e', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (47, '旅游规划师', '✈️', '负责旅游产品设计、行程规划与客户旅行体验优化', 'coming_soon', '#3498db', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (48, '餐饮管理', '🍽️', '负责餐饮门店运营、菜品研发与顾客体验管理', 'coming_soon', '#e67e22', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (49, '人力资源专家', '👥', '负责人才招聘、培训发展、绩效管理与组织文化建设', 'coming_soon', '#2ecc71', 0, '2026-07-16 19:41:49', NULL);
INSERT INTO `careers` VALUES (50, '项目经理', '📋', '负责项目全流程管理、资源协调与交付质量把控', 'coming_soon', '#9b59b6', 0, '2026-07-16 19:41:49', NULL);
=======
INSERT INTO `careers` VALUES (5, '后端开发工程师', '🖥️', '负责服务器端逻辑、API接口开发、数据库设计与优化，是互联网系统的核心支撑', 'active', '#00d4ff', 5, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (6, '前端开发工程师', '🎨', '负责网页/APP界面交互、用户体验优化，让产品好看又好用', 'coming_soon', '#ff6b6b', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (7, '运维/DevOps工程师', '⚙️', '负责系统部署、监控告警、性能调优，保障服务稳定运行', 'coming_soon', '#ffd93d', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (8, '数据分析师', '📊', '负责数据采集、清洗、建模和可视化，用数据驱动业务决策', 'coming_soon', '#6bcb77', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (9, 'AI/机器学习工程师', '🤖', '负责构建智能算法模型，推动人工智能在业务场景中落地', 'coming_soon', '#a66cff', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (10, '网络安全工程师', '🔒', '负责系统安全防护、漏洞挖掘与修复，守护数字资产安全', 'coming_soon', '#ff6b6b', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (11, '移动开发工程师', '📱', '负责iOS/Android端APP开发与维护，打造流畅的移动体验', 'coming_soon', '#4ecdc4', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (12, '云计算架构师', '☁️', '负责云平台架构设计与优化，构建高可用、可扩展的云原生系统', 'coming_soon', '#00b4d8', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (13, '区块链开发工程师', '⛓️', '负责区块链底层技术研发与智能合约开发，推动去中心化应用落地', 'coming_soon', '#f77f00', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (14, '银行客户经理', '🏦', '负责银行客户关系维护、金融产品推荐与销售，提供综合金融服务方案', 'coming_soon', '#003366', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (15, '证券分析师', '📈', '负责证券市场研究、投资策略分析与报告撰写，为投资者提供决策依据', 'coming_soon', '#1a5276', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (16, '保险精算师', '📋', '负责保险产品费率测算、风险评估与准备金评估，是保险公司的核心岗位', 'coming_soon', '#2e4053', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (17, '投资银行家', '💰', '负责企业融资、并购重组、上市辅导等资本市场业务', 'coming_soon', '#1a2a4a', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (18, '财务分析师', '📉', '负责企业财务数据分析、预算编制与经营决策支持', 'coming_soon', '#2c3e50', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (19, '风控经理', '🛡️', '负责金融风险识别、评估与控制，确保业务合规与资产安全', 'coming_soon', '#e74c3c', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (20, '临床医生', '👨‍⚕️', '负责疾病诊断、治疗方案制定与患者管理，守护生命健康', 'coming_soon', '#2e86c1', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (21, '护理师', '👩‍⚕️', '负责患者护理、健康监测与医疗辅助，是医疗团队的重要成员', 'coming_soon', '#5dade2', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (22, '药剂师', '💊', '负责药品配发、用药指导与药物管理，保障患者用药安全', 'coming_soon', '#27ae60', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (23, '公共卫生专家', '🌍', '负责疾病预防、健康教育与公共卫生政策制定与实施', 'coming_soon', '#1a8c4a', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (24, '医疗影像技师', '🩻', '负责CT、MRI、X光等医学影像设备操作与图像采集', 'coming_soon', '#3498db', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (25, '教师', '📚', '负责课程教学、学生辅导与教育研究，培养未来人才', 'coming_soon', '#e67e22', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (26, '教育管理专家', '🏫', '负责学校运营管理、教育政策制定与教育资源统筹', 'coming_soon', '#d4ac0d', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (27, '教育技术专家', '💻', '负责在线教育平台研发、教育产品设计与教育信息化建设', 'coming_soon', '#2ecc71', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (28, '课程设计师', '📝', '负责课程体系设计、教学资源开发与学习体验优化', 'coming_soon', '#f39c12', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (29, '律师', '⚖️', '负责法律咨询、案件代理与法律文书撰写，维护当事人合法权益', 'coming_soon', '#8e44ad', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (30, '法务专员', '📄', '负责企业合同审核、合规管理与法律风险防控', 'coming_soon', '#9b59b6', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (31, '知识产权专员', '📜', '负责专利、商标、版权等知识产权申请与保护工作', 'coming_soon', '#6c3483', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (32, '平面设计师', '🎨', '负责品牌视觉设计、广告创意与平面物料制作', 'coming_soon', '#e84393', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (33, 'UI/UX设计师', '🖌️', '负责产品界面设计与用户体验优化，提升产品易用性', 'coming_soon', '#fd79a8', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (34, '插画师', '✏️', '负责商业插画、绘本创作与视觉艺术表达', 'coming_soon', '#fdcb6e', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (35, '动画师', '🎬', '负责2D/3D动画制作、特效设计与影视后期合成', 'coming_soon', '#e17055', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (36, '品牌经理', '🏷️', '负责品牌战略规划、市场定位与品牌价值提升', 'coming_soon', '#0984e3', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (37, '数字营销专家', '📱', '负责SEO/SEM、社交媒体运营与数字广告投放，提升品牌影响力', 'coming_soon', '#00b894', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (38, '市场分析师', '📊', '负责市场调研、竞品分析与消费者洞察，为决策提供数据支持', 'coming_soon', '#00cec9', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (39, '土木工程师', '🏗️', '负责建筑工程设计、施工管理与结构安全评估', 'coming_soon', '#d35400', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (40, '电气工程师', '⚡', '负责电力系统设计、电气设备选型与自动化控制', 'coming_soon', '#f39c12', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (41, '机械工程师', '🔧', '负责机械设备设计、制造工艺优化与生产管理', 'coming_soon', '#7f8c8d', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (42, '建筑设计师', '🏛️', '负责建筑方案设计、空间规划与建筑美学表达', 'coming_soon', '#a0522d', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (43, '新闻记者', '🎤', '负责新闻采访、报道与内容采编，传递真实、客观的新闻资讯', 'coming_soon', '#2c3e50', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (44, '新媒体运营', '📱', '负责新媒体内容策划、用户运营与品牌传播', 'coming_soon', '#e74c3c', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (45, '视频编导', '🎥', '负责视频内容策划、拍摄执导与后期制作统筹', 'coming_soon', '#f39c12', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (46, '酒店经理', '🏨', '负责酒店运营管理、客户服务与团队建设', 'coming_soon', '#34495e', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (47, '旅游规划师', '✈️', '负责旅游产品设计、行程规划与客户旅行体验优化', 'coming_soon', '#3498db', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (48, '餐饮管理', '🍽️', '负责餐饮门店运营、菜品研发与顾客体验管理', 'coming_soon', '#e67e22', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (49, '人力资源专家', '👥', '负责人才招聘、培训发展、绩效管理与组织文化建设', 'coming_soon', '#2ecc71', 0, '2026-07-16 19:41:49');
INSERT INTO `careers` VALUES (50, '项目经理', '📋', '负责项目全流程管理、资源协调与交付质量把控', 'coming_soon', '#9b59b6', 0, '2026-07-16 19:41:49');
>>>>>>> 9ddca126966f1b1d88318a99a242719f22925f14

-- ----------------------------
-- Table structure for knowledge_cards
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_cards`;
CREATE TABLE `knowledge_cards`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `career_id` int NOT NULL,
  `category` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `icon` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '?',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_knowledge_career`(`career_id` ASC) USING BTREE,
  CONSTRAINT `fk_knowledge_career` FOREIGN KEY (`career_id`) REFERENCES `careers` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of knowledge_cards
-- ----------------------------
INSERT INTO `knowledge_cards` VALUES (1, 5, '后端基础', '什么是后端开发？', '后端开发是指服务器端的软件开发，负责处理业务逻辑、数据库交互、API接口设计、系统架构等。后端工程师就像一栋大楼的“地基”和“骨架”，支撑着整个系统的稳定运行。', '🏗️');
INSERT INTO `knowledge_cards` VALUES (2, 5, '技术栈', 'Java', 'Java 是后端开发最主流的语言之一，拥有丰富的生态和成熟的框架（如 Spring Boot）。其“一次编写，到处运行”的特性使其在企业级应用中占据主导地位。', '☕');
INSERT INTO `knowledge_cards` VALUES (3, 5, '技术栈', 'Spring Boot', 'Spring Boot 是 Java 后端开发最流行的框架，它极大地简化了 Spring 应用的初始搭建和开发过程。通过“自动配置”和“起步依赖”，让开发者能快速构建生产级应用。', '🍃');
INSERT INTO `knowledge_cards` VALUES (4, 5, '技术栈', 'MySQL', 'MySQL 是最流行的开源关系型数据库，后端开发必备技能。掌握索引优化、SQL调优、事务隔离级别等，是区分初级和高级开发的重要标准。', '🐬');
INSERT INTO `knowledge_cards` VALUES (5, 5, '技术栈', 'Redis', 'Redis 是内存数据库，常用于缓存、分布式锁、消息队列等场景。高并发系统中，Redis 是提升性能的利器，面试必问。', '🔴');
INSERT INTO `knowledge_cards` VALUES (6, 5, '日常工具', 'Git', 'Git 是分布式版本控制系统，所有开发者的必备工具。掌握分支管理、冲突解决、代码回滚是团队协作的基础。', '📂');
INSERT INTO `knowledge_cards` VALUES (7, 5, '日常工具', 'Linux', '后端开发通常在 Linux 服务器上部署和运行代码，所以熟悉 Linux 常用命令、文件权限、进程管理是基本要求。', '🐧');
INSERT INTO `knowledge_cards` VALUES (8, 5, '架构设计', '微服务架构', '微服务是将一个大型应用拆分为多个独立服务，每个服务专注一个业务领域。优点是可独立部署、技术异构、故障隔离；缺点是运维复杂度增加。', '🧩');
INSERT INTO `knowledge_cards` VALUES (9, 5, '架构设计', 'RESTful API', 'RESTful API 是后端接口设计的标准风格，使用 HTTP 方法（GET、POST、PUT、DELETE）表示操作，资源用 URL 表示。设计良好的 API 是前后端协作的基础。', '🌐');
INSERT INTO `knowledge_cards` VALUES (10, 5, '职业成长', '后端开发学习路线', '初级 → 掌握一门语言（Java/Go/Python）和基础框架 → 中级 → 深入数据库、缓存、消息队列 → 高级 → 架构设计、性能调优、技术选型 → 架构师 → 系统设计、技术战略。', '📈');

-- ----------------------------
-- Table structure for quests
-- ----------------------------
DROP TABLE IF EXISTS `quests`;
CREATE TABLE `quests`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `scene_id` int NOT NULL,
  `quest_order` tinyint NOT NULL DEFAULT 1,
  `quest_type` enum('choice','click') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'choice',
  `npc_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `options` json NULL,
  `correct_index` tinyint NULL DEFAULT -1,
  `knowledge_point` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `reward_text` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_scene`(`scene_id` ASC) USING BTREE,
  CONSTRAINT `fk_quest_scene` FOREIGN KEY (`scene_id`) REFERENCES `scenes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of quests
-- ----------------------------
INSERT INTO `quests` VALUES (1, 1, 1, 'choice', '导师王工', '王工问：后端开发每天到岗后第一件事是什么？', '导师王工想考考你对后端开发日常的了解。', '[\"刷手机等开饭\", \"看邮件和晨会准备\", \"直接开始写代码\"]', 1, '后端工程师的日常从检查邮件、同步团队进度开始，晨会是了解今天工作重点的关键环节。', '“不错，保持这个习惯，走，去开晨会！”');
INSERT INTO `quests` VALUES (2, 2, 1, 'choice', '产品经理Lisa', 'Lisa问：这个短链接服务，预估峰值QPS（每秒请求数）大概多少？', 'Lisa想确认你对并发量的预估能力。', '[\"不用管，能跑就行\", \"先问业务方推广计划，预估10万QPS\", \"随便写个1000\"]', 1, 'QPS是后端架构选型的核心依据。高并发场景需要引入缓存、消息队列、读写分离等方案，一定要提前确认。', 'Lisa点头：“靠谱，我就按这个量级推广。”');
INSERT INTO `quests` VALUES (3, 3, 1, 'choice', '导师王工', '王工来巡场：写接口时，遇到复杂业务逻辑应该怎么处理？', '王工想看看你的代码设计能力。', '[\"全部写在一个方法里\", \"拆分成多个小方法，每个方法只做一件事\", \"复制粘贴之前项目的代码\"]', 1, '单一职责原则是编码基本功。拆分方法让代码可读性更强、更易测试和维护，这是专业后端和业余的重要区别。', '“很好，代码就是要像乐高一样，一块一块拼。”');
INSERT INTO `quests` VALUES (4, 4, 1, 'choice', '测试同事小陈', '小陈提了个bug：接口偶尔超时。你应该先做什么？', '小陈等你排查问题。', '[\"重启服务器\", \"查日志看慢SQL和接口耗时\", \"告诉小陈是他网络问题\"]', 1, '排查问题第一步永远是看日志。后端工程师的日常就是跟日志打交道，能快速定位问题是核心能力。', '“小陈：对对对，你查日志发现是数据库少建了个索引！”');
INSERT INTO `quests` VALUES (5, 5, 1, 'choice', '运维大哥', '运维问：上线后最需要关注什么指标？', '运维大哥想考你的运维意识。', '[\"服务器CPU温度\", \"接口成功率、响应时间、错误日志\", \"今天几点下班\"]', 1, '上线后要盯着三大黄金指标：成功率（是否可用）、响应时间（快不快）、错误日志（有没有坑）。这是后端工程师的责任心体现。', '“运维大哥竖起大拇指：专业！”');

-- ----------------------------
-- Table structure for scenes
-- ----------------------------
DROP TABLE IF EXISTS `scenes`;
CREATE TABLE `scenes`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `career_id` int NOT NULL,
  `scene_order` tinyint NOT NULL,
  `scene_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `scene_subtitle` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `narrative_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `camera_pos_x` decimal(5, 2) NULL DEFAULT 0.00,
  `camera_pos_y` decimal(5, 2) NULL DEFAULT 5.00,
  `camera_pos_z` decimal(5, 2) NULL DEFAULT 12.00,
  `scene_config` json NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_career_order`(`career_id` ASC, `scene_order` ASC) USING BTREE,
  CONSTRAINT `fk_scene_career` FOREIGN KEY (`career_id`) REFERENCES `careers` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of scenes
-- ----------------------------
INSERT INTO `scenes` VALUES (1, 5, 1, '前台报到', '上午 9:30', '欢迎来到极客科技！今天是你的第一天实习，先到前台打卡，导师会来接你。', 0.00, 4.00, 10.00, NULL);
INSERT INTO `scenes` VALUES (2, 5, 2, '会议室·需求评审', '上午 10:00', '产品经理正在讲解新项目\"短链接生成服务\"的需求，你要认真听，导师随时会提问。', -2.00, 3.00, 8.00, NULL);
INSERT INTO `scenes` VALUES (3, 5, 3, '工位·编码开发', '下午 14:00', '需求确认完毕，回到工位开始写代码。隔壁的前端同事在催接口，测试同事也在盯着你。', 1.00, 4.00, 9.00, NULL);
INSERT INTO `scenes` VALUES (4, 5, 4, '联调区·对接测试', '下午 16:00', '前端和测试同事来找你联调了，接口跑通了吗？bug修完了吗？', 0.00, 3.00, 10.00, NULL);
INSERT INTO `scenes` VALUES (5, 5, 5, '监控大屏·上线', '下午 18:00', '终于上线了！监控大屏上跳动着实时请求数据，你写的服务正在被用户使用。', 0.00, 6.00, 15.00, NULL);

-- ----------------------------
-- Table structure for user_progress
-- ----------------------------
DROP TABLE IF EXISTS `user_progress`;
CREATE TABLE `user_progress`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `session_uuid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `career_id` int NOT NULL,
  `current_scene_id` int NULL DEFAULT 1,
  `quest_answers` json NULL,
  `total_score` tinyint NULL DEFAULT 0,
  `is_finished` tinyint(1) NULL DEFAULT 0,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_session`(`session_uuid` ASC) USING BTREE,
  INDEX `fk_progress_career`(`career_id` ASC) USING BTREE,
  CONSTRAINT `fk_progress_career` FOREIGN KEY (`career_id`) REFERENCES `careers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_progress
-- ----------------------------
INSERT INTO `user_progress` VALUES (1, 'test-session-001', 5, 5, '{\"1\": 1, \"2\": 1, \"3\": 1, \"4\": 1, \"5\": 1}', 5, 1, '2026-07-16 20:35:25', '2026-07-16 20:35:25');

SET FOREIGN_KEY_CHECKS = 1;
