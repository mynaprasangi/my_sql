use project;
show tables
select * from appdoc 
select * from appdoctype_lookup
select * from application
select * from chemtypelookup
select * from doctype_lookup
select * from product
select * from product_tecode
select * from regactiondate
select * from reviewclass_lookup

---------------------------task1--------------------------


#1.1 Determine the number of drugs approved each year and provide insights into the yearly trends.

SELECT YEAR(docdate) AS approval_year,
COUNT(*) AS num_drugs_approved FROM appdoc
GROUP BY YEAR(docdate)
ORDER BY approval_year;

#1.2 Identify the top three years that got the highest and lowest approvals, in descending and ascending order, respectively.

SELECT approval_year, num_drugs_approved
FROM ( SELECT YEAR(docdate) AS approval_year, COUNT(*) AS num_drugs_approved FROM appdoc
GROUP BY approval_year) AS approval_counts
ORDER BY num_drugs_approved DESC
LIMIT 3;

----------- Top three years with the lowest number of drug approvals------------
SELECT approval_year, num_drugs_approved
FROM ( SELECT YEAR(docdate) AS approval_year, COUNT(*) AS num_drugs_approved
FROM appdoc GROUP BY approval_year) AS approval_counts
ORDER BY num_drugs_approved ASC
LIMIT 3;

#1.3 Explore approval trends over the years based on sponsors.

SELECT YEAR(da.docdate) AS approval_year, s.sponsorapplicant,
COUNT(*) AS num_drugs_approved FROM appdoc da JOIN application s ON da.applno = s.applno
GROUP BY approval_year, s.sponsorapplicant
ORDER BY approval_year, num_drugs_approved DESC;
    
 #1.4 Rank sponsors based on the total number of approvals they received each year between 1939 and 1960   
    
----- Assuming the drug_approvals table structure and data

------ Rank sponsors based on the total number of approvals each year between 1939 and 1960

SELECT b.sponsorapplicant,YEAR(a.docdate) AS approval_year, COUNT(*) AS num_drugs_approved,
RANK() OVER(PARTITION BY YEAR(a.docdate) ORDER BY COUNT(*) DESC) AS approval_rank FROM appdoc a JOIN application b 
ON a.applno = b.applno
WHERE YEAR(a.docdate) BETWEEN 1939 AND 1960
GROUP BY b.sponsorapplicant, approval_year
ORDER BY approval_year, num_drugs_approved DESC;


---------------------task 2-------------------

#2.1 Group products based on MarketingStatus. Provide meaningful insights into the segmentation patterns

SELECT ProductMktStatus,COUNT(*) AS num_products FROM product
GROUP BY ProductMktStatus
ORDER BY num_products DESC;

#2.2 Calculate the total number of applications for each MarketingStatus year-wise after the year 2010

SELECT YEAR(da.docdate) AS approval_year,m.ProductMktStatus,
SUM(m.applno) AS total_applications
FROM product m join appdoc da on da.applno= m.applno
WHERE YEAR(da.docdate) > 2010
GROUP BY YEAR(da.docdate), m.ProductMktStatus
ORDER BY approval_year, total_applications DESC;

#2.3 Identify the top MarketingStatus with the maximum number of applications and analyze its trend over time

-- Assuming the applications table structure and data

-- Identify the top MarketingStatus with the maximum number of applications

SELECT ProductMktStatus, SUM(applno) AS total_applications
FROM product
GROUP BY ProductMktStatus
ORDER BY total_applications DESC
LIMIT 1;

------------------task 3-------------------

#3.1 Categorize Products by dosage form and analyze their distribution

SELECT Dosage,Form, COUNT(*) AS num_products,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM product), 2) AS percentage_of_total
FROM product
GROUP BY Dosage, Form
ORDER BY num_products DESC;

#3.2 Calculate the total number of approvals for each dosage form and identify the most successful forms

-- Assuming the drug_approvals table structure and data

-- Calculate the total number of approvals for each dosage form

create table most_successful_drug_form(SELECT p.Form,COUNT(d.applno) AS total_approvals
FROM product p
JOIN regactiondate d ON p.applno = d.applno
GROUP BY p.Form
ORDER BY total_approvals DESC
LIMIT 1);

select * from most_successful_drug_form

#3.3  Investigate yearly trends related to successful forms.

-- Assuming the drug_approvals table structure and data

-- Investigate yearly trends related to successful forms
SELECT YEAR(ad.DocDate) AS Year, p.Form,COUNT(*) AS SalesCount
FROM product p
JOIN appdoc ad ON p.ApplNo = ad.ApplNo
WHERE ad.actiontype = 'ap' 
GROUP BY Year,p.Form
ORDER BY Year ASC,SalesCount DESC;

------------ task 4----------------------

#4.1 Analyze drug approvals based on therapeutic evaluation code (TE_Code)

-- Assuming the drug_approvals table structure and data

-- Analyze drug approvals based on Therapeutic Evaluation Code (TE_Code)
SELECT TECode, COUNT(Drugname) 
FROM product
GROUP BY TECode;

#4.2 Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in each year.

WITH ApprovalCounts AS ( SELECT p.TECode, YEAR(ra.ActionDate) AS ApprovalYear, COUNT(*) AS ApprovalCount,
ROW_NUMBER() OVER (PARTITION BY YEAR(ra.ActionDate) ORDER BY COUNT(*) DESC) AS RowNum
FROM regactiondate ra JOIN product p ON ra.ApplNo = p.ApplNo
WHERE ra.ActionType = 'Ap'  -- Consider only Approval actions
GROUP BY p.TECode, YEAR(ra.ActionDate)
)
SELECT TECode, ApprovalYear, ApprovalCount FROM ApprovalCounts
WHERE RowNum = 1;





