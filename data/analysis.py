# import statements
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots


def main():
    path = 'sales_data_analysis/data'
    sales_data = pd.read_csv(path+'/Sales_Transaction_reformatted.csv')

    # preprocess data - unnecessary due to no real action
    #sales_data = preprocessing(sales_data)

    # transform data - add new columns
    sales_data = transforming(sales_data)

    # analyze data
    analysis(sales_data)


"""
data preprocessing:
check missing values
"""
"""
def preprocessing(data):

    # check missing values
    null_val = data.isnull().sum()
    #print(null_val)

    # 55 missing values in CustomerNo
    #print(sales_data[sales_data['CustomerNo'].isnull()])

    # missing values include both completed and canceled orders - keep

    return data
"""


"""
data transformation:
splitting columns as needed
date into year/month,day
new column to display non-negative quantity bought
new column for final price of quantity * price
"""
def transforming(data):

    # split Date into Year, Month, and Day columns
    index = data.columns.get_loc('Date')
    temp = data['Date'].str.split("-", expand=True).astype('int')
    temp1 = data['Date'].str.split("-", expand=True)
    temp.columns = temp1.columns = ['Year', 'Month', 'Day']
    data.insert(index+1, 'Year', temp['Year'])
    data.insert(index+2, 'Month', temp['Month'])
    data.insert(index+3, 'Day', temp['Day'])
    data.insert(index+4, 'Year-Month', temp1['Year']+'-'+temp1['Month'])

    # add new column for items actually bought -> canceled items as 0
    index = data.columns.get_loc('Quantity')
    temp = data[['TransactionNo', 'Quantity']]
    temp.insert(2, 'QuantitySold', temp['Quantity'])
    temp.loc[temp['TransactionNo'].str[0] == 'C', 'QuantitySold'] = 0
    data.insert(index+1, 'QuantitySold', temp['QuantitySold'])

    # add column for quantity x price
    index = data.columns.get_loc('QuantitySold')
    data.insert(index+1, 'FinalPrice', data['Price']*data['QuantitySold'])

    # sort by date, transaction no
    data = data.sort_values(['Date', 'TransactionNo'], ascending=True).reset_index()
    
    return data


"""
this method contains data analysis for this project.
questions:
"""
def analysis(data):

    # 23204 total transactions, 19790 completed transactions
    #   3414 canceled (math and code checks out -> unneeded now)
    noncanceled = data[data['QuantitySold'] > 0]

    
    """
    monthly sales and best/worst selling products
    """
    #productSales(noncanceled)
    

    """group transactions - TransactionNo/total lines"""
    transactions(noncanceled)


    """customer stats - CustomerNo/ProductNo/Quantity"""
    customers = noncanceled.groupby(['CustomerNo'])

    # total orders (made in a year)?
    #print(customers.aggregate({'TransactionNo':'count'}))

    # number of times purchasing an item
    customerProduct = noncanceled.groupby(['CustomerNo', 'ProductNo'])
    #print(customerProduct.aggregate({'ProductNo':'count'}))


"""
this method contains the analysis of product sales
focuses on time of month/year and total sales
"""
def productSales(data):

    # group and aggregate data
    sales = data.groupby(['Year-Month'])
    products = data.groupby(['ProductNo', 'ProductName'])


    """
    best time of year for sales/purchases
    line to show quantity of items purchases

    most sales and income september-november -> leading to holiday season
    least sales december 2019 -> not enough data? compared to december 2018
    least sales february and april -> not around or leading to anything?
    ---
    rename line trace to Quantity
    rename axes
    change colors?
    show ticks for all x-axis values
    add title
    """
    monthlySales = sales.aggregate(
        {'Quantity':'sum', 'FinalPrice':'sum'}).sort_values(
        ['Year-Month']).reset_index()
    maxSales = monthlySales['FinalPrice'].max()
    msPlot = px.bar(monthlySales, x='Year-Month', y='FinalPrice',
                    range_x=['2018-12', '2019-12'], range_y=[0, maxSales])
    msPlot.add_trace(go.Line(x=monthlySales['Year-Month'],
                             y=monthlySales['Quantity']))
    #msPlot.show()

    
    """
    best and worst selling products by quantity and transactions

    top selling product had only 1 transaction
    worst selling products sold 1 time with a quantity of 1 - one-time gift?
    ---
    fix axes labels, colors
    add title
    hover data for add trace?
    """
    productsSold = products.aggregate({
        'QuantitySold':'sum', 'TransactionNo':'count'}).sort_values([
            'QuantitySold'], ascending=False)
    bestWorst = productsSold.head(10).append(
        productsSold.tail(10)).reset_index()

    bwSellPlot = px.bar(bestWorst, x='ProductName',
                        y='QuantitySold', log_y=True)
    bwSellPlot.add_trace(go.Line(x=bestWorst['ProductName'],
                                 y=bestWorst['TransactionNo']))
    bwSellPlot.update_xaxes(tickangle=270)
    #bwSellPlot.show()
    

"""
this method contains the analysis regarding transactions
includes location, 
"""
def transactions(data):

    transac = data.groupby(['TransactionNo'])
    # total number of transactions
    #print(transac.aggregate(NumItemsPerTransaction=('Quantity', 'count')))

    # total spent per transaction
    # what is the total number of sales?
    transacSpent = data.aggregate({
        'Price':'sum', 'QuantitySold':'sum'}).reset_index()
    #print(transacSpent)

    """
    graph transactions and customers each month
        group by transactionno
        - data contains several lines for different items in same transaction
        group by customerno
        - customers can make different transactions each month
        group by month
        - horizontal axis for plot
    ---
    rename labels
    fix colors     
    """
    monthlyTransac = data.groupby(['Year-Month', 'CustomerNo',
                                   'TransactionNo'])
    monthlyTransac = monthlyTransac.aggregate({
        'FinalPrice':'sum'}).reset_index()
    # group and count transactions for each customer
    monthlyTransac  = monthlyTransac.groupby(['Year-Month', 'CustomerNo'])
    monthlyTransac = monthlyTransac.aggregate(
        TotalTransactions=('TransactionNo', 'count')).reset_index()
    # group customers and count transactions for each month
    monthlyTransac = monthlyTransac.groupby(['Year-Month'])
    monthlyTransac = monthlyTransac.aggregate(
        TotalCustomers=('CustomerNo','count'),
        TotalTransactions=('TotalTransactions', 'sum')).reset_index()

    transacPlot = px.line(monthlyTransac, x='Year-Month',
                          y=['TotalCustomers', 'TotalTransactions'],
                          range_x=['2018-12', '2019-12'], range_y=[0, 3000])
    transacPlot.show()


"""
desc
"""
def m3():
    z = 3
    # group and aggregate data

    # graph


if __name__ == '__main__':
    main()