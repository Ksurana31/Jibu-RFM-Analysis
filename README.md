# 💧 Jibu RFM Analysis – Optimizing Customer Lifetime Value (CLV)

### 📌 Project Overview
Jibu is a **social enterprise** dedicated to providing **affordable and clean drinking water** across Africa through a **franchise model**. This project applies **data analytics and machine learning techniques** to optimize **Customer Lifetime Value (CLV)**, which is critical for **business sustainability, franchise success, and resource allocation**.

### 🎯 Objectives
- **Enhance Customer Lifetime Value (CLV)** by identifying key business drivers.
- **Segment franchises** using **RFM (Recency, Frequency, Monetary) analysis**.
- **Develop predictive models** to optimize marketing strategies.
- **Improve franchise operations** using insights from CLV and clustering.

---

## 🚀 Features & Methodology
This project follows a structured **data-driven approach**:

### **1️⃣ Data Collection & Cleaning**
✔ **Datasets Used:**  
   - **Meters Reading Data** (Water production per franchise, monthly records).  
   - **Health Dataset** (Retailer satisfaction, hygiene audits, sales & expenses).  
✔ **Data Cleaning Steps:**  
   - Standardized column names and converted dates.  
   - Removed outliers and missing values.  
   - Merged datasets using **Franchise ID**.  
✔ **Final Dataset:**  
   - **4,585 records** from water production logs.  
   - **1,045 records** from health & sales reports.  

---

### **2️⃣ Exploratory Data Analysis (EDA)**
📌 **Key Findings:**  
✔ **Production Trends** – Average monthly liters produced: **66,669** (Median: **53,823**).  
✔ **Market Share** – Rwanda leads production (**44%**), followed by Uganda (**26%**).  
✔ **Satisfaction Scores** – Median retailer satisfaction: **6.58/65.22**; Branding score: **31.44/85**.  
✔ **Operational Variation** – Franchise expenses range from **$0 to $817,105**, showing high variability.  

---

### **3️⃣ RFM Analysis for Customer Segmentation**
📌 **Recency (R):** Last water production date per franchise.  
📌 **Frequency (F):** Number of months water was produced.  
📌 **Monetary (M):** Total liters produced by a franchise.  
✔ **Data Transformation:** Used **log transformations** to normalize distribution.  
✔ **Correlation Analysis:** Monetary value & Frequency correlation: **0.56**.  

---

### **4️⃣ K-Means Clustering for Franchise Segmentation**
✔ **Optimal Clusters Identified:** **8 clusters** using **Silhouette Scores & WSS**.  
✔ **Cluster Characteristics:**  
   - **High CLV Segments (77% of franchises)** – High production, frequent transactions.  
   - **Low CLV Segments** – New or struggling franchises needing targeted strategies.  
✔ **Actionable Insights:**  
   - Tailor marketing efforts per cluster.  
   - Boost performance of low-CLV franchises through training & incentives.  

---

### **5️⃣ Customer Lifetime Value (CLV) Calculation**
📌 **Formula Used:**  
\[
CLV = \frac{\text{liters produced}}{(1 + \text{US Interest Rate})^{\text{Month Present}}}
\]
✔ **Factors Considered:**  
   - **Time-based value adjustments** using historical **interest rates**.  
   - **Aggregated CLV per franchise** to track long-term value.  

---

### **6️⃣ Regression Analysis – Identifying CLV Drivers**
📌 **Key Predictors Identified:**  
✔ **Liters Produced** – More production leads to higher CLV.  
✔ **Hygiene Audit Score** – High scores = Greater customer trust & repeat transactions.  
✔ **Retailer Satisfaction Score** – Direct impact on **Adjusted Sales**.  
✔ **Staff Count** – More employees contribute to **better franchise performance**.  

📈 **Final Model Performance:**  
   - **Adjusted R² = 85%** → High predictive accuracy.  
   - **Retailer Satisfaction & Hygiene Score** were significant predictors of **CLV growth**.  

---

## 📊 Key Business Insights
📌 **For High CLV Franchises:**  
✔ Focus on **customer retention strategies** – loyalty rewards, premium service offerings.  
✔ Leverage strong branding to expand influence and attract more end-users.  

📌 **For Low CLV Franchises:**  
✔ Implement **training programs** to improve **hygiene & operational efficiency**.  
✔ Provide **financial support & incentives** for franchise owners to scale up production.  

📌 **General Strategy:**  
✔ Strengthen **franchisee relationships** to enhance business success.  
✔ Monitor **operational performance metrics** to optimize resource allocation.  

---

## 🛠️ Technologies Used
- **Python (Pandas, NumPy, Scikit-learn, Matplotlib, Seaborn)** – Data processing, clustering, visualization.
- **R (caret, stats, factoextra, ggplot2)** – CLV modeling, regression analysis, and clustering.
- **SQL** – Data extraction & transformation.
- **Tableau / Power BI** – Data visualization for business insights.

---

## 📜 Conclusion
This study **unlocks data-driven insights** to improve **customer retention, operational efficiency, and strategic decision-making** at Jibu. By applying **RFM segmentation, clustering, and predictive modeling**, Jibu can:  
✅ **Increase customer lifetime value** through data-backed business decisions.  
✅ **Enhance franchise operations** by optimizing marketing & engagement strategies.  
✅ **Ensure long-term growth** by leveraging **data science in business strategy**.  

