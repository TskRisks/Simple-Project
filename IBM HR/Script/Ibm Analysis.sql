-- Dataset from "https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset/data"

-- ------------------------------------------------------------ Data Quality Check ------------------------------------------------------------ -- 
-- Checking the data type in each column
DESCRIBE employee_attrition;

-- 
SELECT *
FROM employee_attrition;

-- Checking for null values
SELECT 
	CASE
	WHEN Age IS NULL THEN TRUE 
    WHEN Attrition IS NULL THEN TRUE
    WHEN BusinessTravel IS NULL THEN TRUE
    WHEN DailyRate IS NULL THEN TRUE
	WHEN Department IS NULL THEN TRUE
    WHEN DistanceFromHome IS NULL THEN TRUE
    WHEN Education IS NULL THEN TRUE
    WHEN EducationField IS NULL THEN TRUE
	WHEN EmployeeCount IS NULL THEN TRUE -- Remove this If you want to check again for the null Values(Don't remove it if you haven't Alter the table)
	WHEN EmployeeNumber IS NULL THEN TRUE -- Remove this If you want to check again for the null Values(Don't remove it if you haven't Alter the table)
    WHEN EnvironmentSatisfaction IS NULL THEN TRUE
    WHEN Gender IS NULL THEN TRUE
    WHEN HourlyRate IS NULL THEN TRUE
    WHEN JobInvolvement IS NULL THEN TRUE
    WHEN JobLevel IS NULL THEN TRUE
    WHEN Jobrole IS NULL THEN TRUE
	WHEN JobSatisfaction IS NULL THEN TRUE
	WHEN MaritalStatus IS NULL THEN TRUE
	WHEN MonthlyIncome IS NULL THEN TRUE
	WHEN MonthlyRate IS NULL THEN TRUE
    WHEN NumCompaniesWorked IS NULL THEN TRUE
	WHEN Over18 IS NULL THEN TRUE -- Remove this If you want to check again for the null Values(Don't remove it if you haven't Alter the table)
	WHEN OverTime IS NULL THEN TRUE
	WHEN PercentSalaryHike IS NULL THEN TRUE
	WHEN PerformanceRating IS NULL THEN TRUE
	WHEN RelationshipSatisfaction IS NULL THEN TRUE
	WHEN StandardHours IS NULL THEN TRUE -- Remove this If you want to check again for the null Values(Don't remove it if you haven't Alter the table)
	WHEN StockOptionLevel IS NULL THEN TRUE    
    WHEN TotalWorkingYears IS NULL THEN TRUE
	WHEN TrainingTimesLastYear IS NULL THEN TRUE
	WHEN WorkLifeBalance IS NULL THEN TRUE
	WHEN YearsAtCompany IS NULL THEN TRUE
	WHEN YearsInCurrentRole IS NULL THEN TRUE
	WHEN YearsSinceLastPromotion IS NULL THEN TRUE
	WHEN YearsWithCurrManager IS NULL THEN TRUE    
	ELSE FALSE END AS NullCheckResult
FROM employee_attrition;


-- -------------------------------------------------------------- Data Cleaning ------------------------------------------------------------ --
-- Checking for duplicate value. If the results shows none, It means that there is no duplicate values
SELECT ea.*
FROM employee_attrition ea
JOIN (SELECT CONCAT(Age, Attrition, BusinessTravel, DailyRate, Department, DistanceFromHome, Education, EducationField, EmployeeCount, EmployeeNumber, EnvironmentSatisfaction, 
					Gender, HourlyRate, JobInvolvement, JobLevel, JobRole, JobSatisfaction, MaritalStatus, MonthlyIncome, MonthlyRate, NumCompaniesWorked, Over18, OverTime, 
                    PercentSalaryHike, PerformanceRating, RelationshipSatisfaction, StandardHours, StockOptionLevel, TotalWorkingYears, TrainingTimesLastYear, WorkLifeBalance, 
					YearsAtCompany, YearsInCurrentRole, YearsSinceLastPromotion, YearsWithCurrManager) AS concatenated_values
    FROM employee_attrition
    GROUP BY Age, Attrition, BusinessTravel, DailyRate, Department, DistanceFromHome, Education, EducationField, EmployeeCount, EmployeeNumber, EnvironmentSatisfaction, 
            Gender, HourlyRate, JobInvolvement, JobLevel, JobRole, JobSatisfaction, MaritalStatus, MonthlyIncome, MonthlyRate, NumCompaniesWorked, Over18, OverTime, 
            PercentSalaryHike, PerformanceRating, RelationshipSatisfaction, StandardHours, StockOptionLevel, TotalWorkingYears, TrainingTimesLastYear, WorkLifeBalance, 
            YearsAtCompany, YearsInCurrentRole, YearsSinceLastPromotion, YearsWithCurrManager
    HAVING COUNT(*) > 1
	) AS t ON CONCAT(ea.Age, ea.Attrition, ea.BusinessTravel, ea.DailyRate, ea.Department, ea.DistanceFromHome, ea.Education, ea.EducationField, ea.EmployeeCount, ea.EmployeeNumber, 
					ea.EnvironmentSatisfaction, ea.Gender, ea.HourlyRate, ea.JobInvolvement, ea.JobLevel, ea.JobRole, ea.JobSatisfaction, ea.MaritalStatus, ea.MonthlyIncome, 
                    ea.MonthlyRate, ea.NumCompaniesWorked, ea.Over18, ea.OverTime, ea.PercentSalaryHike, ea.PerformanceRating, ea.RelationshipSatisfaction, ea.StandardHours, 
                    ea.StockOptionLevel, ea.TotalWorkingYears, ea.TrainingTimesLastYear, ea.WorkLifeBalance, ea.YearsAtCompany, ea.YearsInCurrentRole, ea.YearsSinceLastPromotion, 
                    ea.YearsWithCurrManager) = t.concatenated_values;

-- Drop or remove a redundant coloumn(Note: Dropping column will be permanently remove from the table)
ALTER TABLE employee_attrition
DROP COLUMN EmployeeCount,
DROP COLUMN EmployeeNumber,
DROP COLUMN Over18,
DROP COLUMN StandardHours;

-- Checking the number of rows and column after dropping some redundant columns
SELECT 
    (SELECT COUNT(*) FROM employee_attrition) AS num_rows,
    (SELECT COUNT(column_name) FROM information_schema.columns WHERE table_name = 'employee_attrition') AS num_columns;


-- ------------------------------------------------------------ Data Exploration ------------------------------------------------------------ --
-- Checking Attrition rate
SELECT Attrition, COUNT(*) as Count,
		concat(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM employee_attrition), 2), '%') as Percentage
FROM employee_attrition
GROUP BY Attrition;

-- Attrition Rate by Gender
SELECT Gender, Attrition, 
		COUNT(*) AS Count,
		CONCAT(ROUND(COUNT(*) * 100 / NULLIF((SELECT COUNT(*) FROM employee_attrition WHERE Gender = atr.Gender), 0), 2), '%') AS Percentage
FROM employee_attrition atr
GROUP BY Gender, Attrition
ORDER BY Gender;

-- Departmnet with a huge Attrition Rate
SELECT Department, Attrition,
		COUNT(*) AS Count,
        CONCAT(ROUND(COUNT(*) * 100 / NULLIF((SELECT COUNT(*) FROM employee_attrition WHERE Department = atr.Department),0),2), '%') AS Percentage
FROM employee_attrition atr
GROUP BY Department, Attrition
ORDER BY Attrition DESC;

-- Check Which Age group leave the company
SELECT ROUND(AVG(Age),0) AS Age_Group, COUNT(*) AS Total
FROM employee_attrition
WHERE Attrition = 'Yes'
GROUP BY Age
ORDER BY Total DESC;

-- job involvement levels among employees who have left and those who have stayed
SELECT Attrition,
		SUM(CASE WHEN JobInvolvement = 1 THEN 1 ELSE 0 END) AS 'Low',
        SUM(CASE WHEN JobInvolvement = 2 THEN 1 ELSE 0 END) AS 'Medium',
        SUM(CASE WHEN JobInvolvement = 3 THEN 1 ELSE 0 END) AS 'High',
        SUM(CASE WHEN JobInvolvement = 4 THEN 1 ELSE 0 END) AS 'Very High'
FROM employee_attrition
GROUP BY Attrition;

-- Job role levels among employees who have left and stayed in the company
SELECT JobRole, 
	SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS 'YES',
    SUM(CASE WHEN Attrition = 'No' THEN 1 ELSE 0 END) AS 'NO'
FROM employee_attrition atr
GROUP BY JobRole;

-- Analyzing gender satisfaction levels based on environment satisfaction ratings
SELECT Gender,
		SUM(CASE WHEN EnvironmentSatisfaction = 1 THEN 1 ELSE 0 END) AS 'Low',
        SUM(CASE WHEN EnvironmentSatisfaction = 2 THEN 1 ELSE 0 END) AS 'Medium',
        SUM(CASE WHEN EnvironmentSatisfaction = 3 THEN 1 ELSE 0 END) AS 'High',
        SUM(CASE WHEN EnvironmentSatisfaction = 4 THEN 1 ELSE 0 END) AS 'Very High'	
FROM employee_attrition
GROUP BY Gender;

-- Check which Department travels a lot 
SELECT
    BusinessTravel,
    SUM(CASE WHEN Department = 'Human Resources' THEN 1 ELSE 0 END) AS HR,
    SUM(CASE WHEN Department = 'Research & Development' THEN 1 ELSE 0 END) AS RnD,
    SUM(CASE WHEN Department = 'Sales' THEN 1 ELSE 0 END) AS Sales
FROM employee_attrition
GROUP BY BusinessTravel;

-- attrition based on work life balance
SELECT WorkLifeBalance, Attrition,
       COUNT(*) AS Count,
       CONCAT(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM employee_attrition), 2), '%') AS Percentage
FROM employee_attrition
GROUP BY WorkLifeBalance, Attrition
ORDER BY Attrition DESC;

-- Checking Trends in years since last promotion
SELECT YearsSinceLastPromotion, Attrition,
       COUNT(*) AS Count,
       CONCAT(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM employee_attrition), 2), '%') AS Percentage
FROM employee_attrition
GROUP BY YearsSinceLastPromotion, Attrition
ORDER BY Attrition DESC;

-- Relationship Satisfaction and attrition by Status
SELECT MaritalStatus, RelationshipSatisfaction, Attrition,
       COUNT(*) AS Count,
       CONCAT(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM employee_attrition), 2), '%') AS Percentage
FROM employee_attrition
GROUP BY MaritalStatus, RelationshipSatisfaction, Attrition
ORDER BY MaritalStatus, RelationshipSatisfaction;

-- Comparing job satisfaction level by Department
SELECT Department, JobSatisfaction, 
       COUNT(*) AS Count,
       CONCAT(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM employee_attrition), 2), '%') AS Percentage
FROM employee_attrition
GROUP BY Department, JobSatisfaction
ORDER BY JobSatisfaction DESC;



-- ------------------------------------------------------------ Statistical Analysis ------------------------------------------------------------ --
-- Distribution of salary hike percentages among employees based on their performance ratings within each department
SELECT Attrition, Department, 
	CONCAT(ROUND(MIN(PercentSalaryHike),0), '%') AS Min_Salary_Hike,
    CONCAT(ROUND(AVG(PercentSalaryHike),0), '%') AS Avg_Salary_Hike,
    CONCAT(ROUND(MAX(PercentSalaryHike),0), '%') AS High_Salary_Hike,
	SUM(CASE WHEN PerformanceRating = 1 THEN 1 ELSE 0 END) AS 'Low',
	SUM(CASE WHEN PerformanceRating = 2 THEN 1 ELSE 0 END) AS 'Medium',
	SUM(CASE WHEN PerformanceRating = 3 THEN 1 ELSE 0 END) AS 'High',
	SUM(CASE WHEN PerformanceRating = 4 THEN 1 ELSE 0 END) AS 'Very High'	
FROM employee_attrition
GROUP BY Attrition, Department
ORDER BY Attrition ASC;

-- EducationField, Department, and Jobrole based on Education Level
SELECT
	CASE Education
		WHEN 1 THEN 'Below College'
        WHEN 2 THEN 'College'
        WHEN 3 THEN 'Bachelor'
        WHEN 4 THEN 'Master'
        WHEN 5 THEN 'Doctor'
        END AS Educational_Level,
 Department, Jobrole,EducationField, COUNT(*) as Total
FROM employee_attrition
GROUP BY Department, JobRole, EducationField, Education
ORDER BY Education;        
        
-- DailyRate based on Education
SELECT
	CASE Education
		WHEN 1 THEN 'Below College'
        WHEN 2 THEN 'College'
        WHEN 3 THEN 'Bachelor'
        WHEN 4 THEN 'Master'
        WHEN 5 THEN 'Doctor'
        END AS Educational_Level,
	AVG(DailyRate) as AvgDailyRate
FROM employee_attrition
GROUP BY Education
ORDER BY Education;

-- monthly income based on Education
SELECT 
	CASE Education
		WHEN 1 THEN 'Below College'
        WHEN 2 THEN 'College'
        WHEN 3 THEN 'Bachelor'
        WHEN 4 THEN 'Master'
        WHEN 5 THEN 'Doctor'
        END AS Educational_Level,
        ROUND(MIN(MonthlyIncome),0) AS MIN_Income_per_Month,
        ROUND(AVG(MonthlyIncome),0) AS AVG_Income_per_Month,
        ROUND(MAX(MonthlyIncome),0) AS HIGH_Income_per_Month
FROM employee_attrition
GROUP BY Education;

-- average Rate per Hour by Gender
SELECT Gender, ROUND(AVG(HourlyRate),2) AS AVGHOURRATE
FROM employee_attrition
GROUP BY GENDER;

-- average monthly income based on their Status, Overtime and number of Employee
SELECT MaritalStatus, OverTime, 
		ROUND(AVG(MonthlyIncome),2) AS AVG_Monthly_Income, 
        COUNT(*) AS Total_Employee
FROM employee_attrition
GROUP BY MaritalStatus, OverTime
ORDER BY MaritalStatus;
       
--  jobSatisfaction By gender
SELECT Gender,
		SUM(CASE WHEN jobsatisfaction = 1 THEN 1 ELSE 0 END) AS 'Low',
        SUM(CASE WHEN jobsatisfaction = 2 THEN 1 ELSE 0 END) AS 'Medium',
        SUM(CASE WHEN jobsatisfaction = 3 THEN 1 ELSE 0 END) AS 'High',
        SUM(CASE WHEN jobsatisfaction = 4 THEN 1 ELSE 0 END) AS 'Very High'
FROM employee_attrition
GROUP BY Gender;

-- Attrition based on Performance Rating
SELECT PerformanceRating, Attrition,
       COUNT(*) AS Count,
       CONCAT(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM employee_attrition), 2), '%') AS Percentage
FROM employee_attrition
GROUP BY PerformanceRating, Attrition
ORDER BY Attrition DESC;

-- Analyzing the impact of training Attrition
SELECT TrainingTimesLastYear, Attrition,
       COUNT(*) AS Count,
       CONCAT(ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM employee_attrition), 2), '%') AS Percentage
FROM employee_attrition
GROUP BY TrainingTimesLastYear, Attrition
ORDER BY Attrition DESC;


/* Key Findings
-The overall attrition rate in the organization stands at 16.12%, indicating lower Attrition rate compare to other industries.
-Variations in attrition rates are evident across genders and departments. Male employees exhibit a higher attrition rate at 
17.01%, compared to females at 14.80%. Within departments, the Sales department shows the highest attrition rate, reaching 20.63%.
- Ages 29 to 31 tends to leave the company.
-Based on the Job Satisfaction in each department, RND(Research and Development has the Highest Job Satisfaction of 20.07%. whereas
the least satisfied department is HR(Human Resource).
-Employees reporting higher work-life balance scores exhibit lower attrition rates, underscoring the importance of promoting 
work-life balance initiatives.
-Performance ratings significantly impact attrition rates, with employees receiving higher ratings demonstrating greater retention.
-Employees with higher education levels tend to earn an average of 8,278 per month. Furthermore, education level influences job roles and career progression.
*/
