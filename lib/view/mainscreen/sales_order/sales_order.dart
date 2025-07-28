import 'package:flutter/material.dart';
import 'package:location_tracker_app/view/mainscreen/sales_order/create_sales_order/create_sales_order.dart';

class SalesOrdersListPage extends StatefulWidget {
  const SalesOrdersListPage({super.key});

  @override
  _SalesOrdersListPageState createState() => _SalesOrdersListPageState();
}

class _SalesOrdersListPageState extends State<SalesOrdersListPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  String _selectedFilter = 'All';
  bool _isFilterExpanded = false;

  // Mock data for sales orders
  final List<SalesOrder> _salesOrders = [
    SalesOrder(
      id: 'SO-20250728-001',
      customerName: 'ABC Corporation',
      orderDate: DateTime.now().subtract(Duration(days: 1)),
      totalAmount: 2450.00,
      status: 'Pending',
      itemCount: 3,
    ),
    SalesOrder(
      id: 'SO-20250727-002',
      customerName: 'XYZ Ltd',
      orderDate: DateTime.now().subtract(Duration(days: 2)),
      totalAmount: 1820.00,
      status: 'Completed',
      itemCount: 5,
    ),
    SalesOrder(
      id: 'SO-20250726-003',
      customerName: 'Tech Solutions Inc',
      orderDate: DateTime.now().subtract(Duration(days: 3)),
      totalAmount: 3200.00,
      status: 'Processing',
      itemCount: 2,
    ),
    SalesOrder(
      id: 'SO-20250725-004',
      customerName: 'Digital Dynamics',
      orderDate: DateTime.now().subtract(Duration(days: 4)),
      totalAmount: 950.00,
      status: 'Cancelled',
      itemCount: 1,
    ),
    SalesOrder(
      id: 'SO-20250724-005',
      customerName: 'Innovation Labs',
      orderDate: DateTime.now().subtract(Duration(days: 5)),
      totalAmount: 4100.00,
      status: 'Completed',
      itemCount: 7,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _filterAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _filterAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  List<SalesOrder> get _filteredOrders {
    if (_selectedFilter == 'All') return _salesOrders;
    return _salesOrders
        .where((order) => order.status == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F6FA), Color(0xFFEDE7F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterSection(),
              _buildStatsCards(),
              Expanded(child: _buildOrdersList()),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildUniqueFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF764BA2), Color(0xFF667EEA)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF764BA2).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.receipt_long, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales Orders',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                ),
                Text(
                  'Manage your sales orders',
                  style: TextStyle(fontSize: 16, color: Color(0xFF636E72)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
                if (_isFilterExpanded) {
                  _filterAnimationController.forward();
                } else {
                  _filterAnimationController.reverse();
                }
              });
            },
            icon: AnimatedRotation(
              turns: _isFilterExpanded ? 0.5 : 0,
              duration: Duration(milliseconds: 300),
              child: Icon(Icons.tune, color: Color(0xFF764BA2), size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return SizedBox(
          height: _filterAnimation.value * 80,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                'All',
                'Pending',
                'Processing',
                'Completed',
                'Cancelled',
              ].map((filter) => _buildFilterChip(filter)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String filter) {
    bool isSelected = _selectedFilter == filter;
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF764BA2),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Color(0xFF764BA2),
        checkmarkColor: Colors.white,
        elevation: isSelected ? 4 : 1,
        shadowColor: Color(0xFF764BA2).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Color(0xFF764BA2) : Color(0xFFE5E5E5),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    int totalOrders = _salesOrders.length;
    double totalRevenue = _salesOrders.fold(
      0,
      (sum, order) => sum + order.totalAmount,
    );
    int pendingOrders = _salesOrders
        .where((order) => order.status == 'Pending')
        .length;

    return Container(
      height: 120,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildStatCard(
            'Total Orders',
            totalOrders.toString(),
            Icons.shopping_cart_outlined,
            Color(0xFF6C5CE7),
          ),
          _buildStatCard(
            'Revenue',
            '\$${totalRevenue.toStringAsFixed(0)}',
            Icons.attach_money,
            Color(0xFF00B894),
          ),
          _buildStatCard(
            'Pending',
            pendingOrders.toString(),
            Icons.pending_actions,
            Color(0xFFE17055),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Color(0xFF636E72))),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: _filteredOrders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(_filteredOrders[index], index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFF764BA2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Color(0xFF764BA2).withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first sales order to get started',
            style: TextStyle(fontSize: 16, color: Color(0xFF636E72)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(SalesOrder order, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _showOrderDetails(order),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF764BA2).withOpacity(0.1),
                            Color(0xFF667EEA).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: Color(0xFF764BA2),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.id,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            order.customerName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF636E72),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F6FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildOrderDetail(
                          'Amount',
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          Icons.attach_money,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Color(0xFFE5E5E5)),
                      Expanded(
                        child: _buildOrderDetail(
                          'Items',
                          '${order.itemCount}',
                          Icons.inventory_2_outlined,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Color(0xFFE5E5E5)),
                      Expanded(
                        child: _buildOrderDetail(
                          'Date',
                          '${order.orderDate.day}/${order.orderDate.month}',
                          Icons.calendar_today_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Completed':
        color = Color(0xFF00B894);
        break;
      case 'Processing':
        color = Color(0xFF0984E3);
        break;
      case 'Pending':
        color = Color(0xFFE17055);
        break;
      case 'Cancelled':
        color = Color(0xFFD63031);
        break;
      default:
        color = Color(0xFF636E72);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF764BA2), size: 16),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3436),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Color(0xFF636E72))),
      ],
    );
  }

  Widget _buildUniqueFloatingButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: Container(
            margin: EdgeInsets.only(bottom: 16, right: 4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow effect
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF764BA2).withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Main button
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF764BA2).withOpacity(0.4),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Navigate to create sales order page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SalesOrderCreatePage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 28),
                            Positioned(
                              bottom: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Animated pulse rings
                ...List.generate(2, (index) {
                  return AnimatedBuilder(
                    animation: _fabAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale:
                            1 +
                            (_fabAnimationController.value * 0.3 * (index + 1)),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                0.3 *
                                    (1 - _fabAnimationController.value) *
                                    (2 - index),
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOrderDetails(SalesOrder order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Order ID: ${order.id}'),
            Text('Customer: ${order.customerName}'),
            Text('Amount: \$${order.totalAmount.toStringAsFixed(2)}'),
            Text('Status: ${order.status}'),
            Text('Items: ${order.itemCount}'),
            Text('Date: ${order.orderDate.toString().substring(0, 10)}'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Data Models
class SalesOrder {
  final String id;
  final String customerName;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final int itemCount;

  SalesOrder({
    required this.id,
    required this.customerName,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.itemCount,
  });
}
