resource "aws_cloudwatch_dashboard" "ghost_dashboard" {
  dashboard_name = "GhostInfrastructureDashboard"

  dashboard_body = jsonencode(
    {
      "widgets" : [
        {
          "height" : 6,
          "width" : 6,
          "y" : 0,
          "x" : 0,
          "type" : "metric",
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT MAX(CPUUtilization)\nFROM SCHEMA(\"AWS/EC2\", InstanceId)\nGROUP BY InstanceId\nORDER BY MAX() DESC\nLIMIT 10", "label" : "$${LABEL} [avg: $${AVG}%]", "id" : "q1", "region" : "us-east-1" }],
              ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "ghost_ec2_pool", { "region" : "us-east-1", "id" : "m1", "visible" : false }]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "us-east-1",
            "period" : 60,
            "stat" : "Average",
            "setPeriodToTimeRange" : true,
            "annotations" : {
              "horizontal" : [
                {
                  "label" : "CPU Threshold",
                  "value" : 90
                }
              ]
            },
            "title" : "Top 10 instances by highest CPU utilization",
            "yAxis" : {
              "left" : {
                "label" : "Percent",
                "showUnits" : false
              }
            }
          }
        },
        {
          "type" : "metric",
          "x" : 6,
          "y" : 0,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT AVG(CPUUtilization) FROM SCHEMA(\"AWS/ECS\", ClusterName,ServiceName) GROUP BY ServiceName", "label" : "CPU", "id" : "q1", "region" : "us-east-1" }]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "us-east-1",
            "period" : 60,
            "stat" : "Average",
            "yAxis" : {
              "left" : {
                "label" : "CPU Percentage",
                "showUnits" : false
              }
            },
            "legend" : {
              "position" : "bottom"
            },
            "liveData" : false,
            "title" : "CPU Percentage ECS tasks"
          }
        },
        {
          "type" : "metric",
          "x" : 12,
          "y" : 0,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT AVG(MemoryUtilization) FROM SCHEMA(\"AWS/ECS\", ClusterName,ServiceName) GROUP BY ServiceName", "id" : "q1", "region" : "us-east-1" }]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "us-east-1",
            "period" : 60,
            "stat" : "Average",
            "yAxis" : {
              "left" : {
                "label" : "Memory Percentage",
                "showUnits" : false
              }
            },
            "legend" : {
              "position" : "bottom"
            },
            "liveData" : false,
            "title" : "CPU Percentage ECS tasks"
          }
        },
        {
          "type" : "metric",
          "x" : 18,
          "y" : 0,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT AVG(RunningTaskCount) FROM SCHEMA(\"ECS/ContainerInsights\", ClusterName,ServiceName) WHERE ClusterName = 'ghost' GROUP BY ClusterName, ServiceName ORDER BY AVG() DESC LIMIT 10", "label" : "$${LABEL} [avg: $${AVG}]", "id" : "q1", "period" : 60 }]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "us-east-1",
            "stat" : "Average",
            "period" : 60,
            "title" : "Number of tasks by ECS Services (Container Insights)",
            "yAxis" : {
              "left" : {
                "label" : "Count",
                "showUnits" : false
              }
            },
            "setPeriodToTimeRange" : true
          }
        },
        {
          "height" : 6,
          "width" : 6,
          "y" : 6,
          "x" : 0,
          "type" : "metric",
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT SUM(ClientConnections) FROM SCHEMA(\"AWS/EFS\", FileSystemId) GROUP BY FileSystemId", "id" : "q1", "label" : "EFS [id: $${LABEL}]", "region" : "us-east-1" }]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "us-east-1",
            "period" : 60,
            "stat" : "Average",
            "title" : "Client connections to EFS by id"
          }
        },
        {
          "type" : "metric",
          "x" : 6,
          "y" : 6,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT AVG(StorageBytes) FROM SCHEMA(\"AWS/EFS\", FileSystemId,StorageClass) WHERE StorageClass = 'Total' GROUP BY FileSystemId", "label" : "$${LABEL} [size: $${AVG}]", "id" : "q1", "region" : "us-east-1" }]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "us-east-1",
            "stat" : "Average",
            "period" : 300,
            "title" : "EFS Storage Size"
          }
        },
        {
          "type" : "metric",
          "x" : 0,
          "y" : 12,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT AVG(DatabaseConnections) FROM SCHEMA(\"AWS/RDS\", DBInstanceIdentifier) GROUP BY DBInstanceIdentifier LIMIT 10", "label" : "$${LABEL} [avg: $${AVG}]", "id" : "q1" }]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "us-east-1",
            "stat" : "Average",
            "period" : 300,
            "title" : "RDS Database connections",
            "yAxis" : {
              "left" : {
                "label" : "Client Connections",
                "showUnits" : false
              }
            }
          }
        },
        {
          "type" : "metric",
          "x" : 6,
          "y" : 12,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT MAX(CPUUtilization) FROM SCHEMA(\"AWS/RDS\", DBInstanceIdentifier) GROUP BY DBInstanceIdentifier LIMIT 10", "label" : "$${LABEL} [avg: $${AVG}%]", "id" : "q1", "region" : "us-east-1" }]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "us-east-1",
            "stat" : "Average",
            "period" : 300,
            "title" : "RDS Instance Max CPU utilization",
            "yAxis" : {
              "left" : {
                "label" : "Percent",
                "showUnits" : false
              }
            }
          }
        },
        {
          "type" : "metric",
          "x" : 12,
          "y" : 6,
          "width" : 12,
          "height" : 6,
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT MAX(WriteIOPS) FROM SCHEMA(\"AWS/RDS\", DBInstanceIdentifier) WHERE DBInstanceIdentifier = 'ghost' GROUP BY DBInstanceIdentifier", "label" : "$${LABEL} Write IOPS [avg: $${AVG}]", "id" : "q1", "region" : "us-east-1", "period" : 60 }]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "us-east-1",
            "stat" : "Average",
            "period" : 60,
            "title" : "RDS Cluster WRITE IOPS",
            "yAxis" : {
              "left" : {
                "label" : "Count",
                "showUnits" : false
              }
            }
          }
        },
        {
          "type" : "metric",
          "x" : 12,
          "y" : 12,
          "width" : 12,
          "height" : 6,
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT MAX(ReadIOPS) FROM SCHEMA(\"AWS/RDS\", DBInstanceIdentifier) WHERE DBInstanceIdentifier = 'ghost' GROUP BY DBInstanceIdentifier", "label" : "$${LABEL} Write IOPS [avg: $${AVG}]", "id" : "q1", "region" : "us-east-1", "period" : 60 }]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "us-east-1",
            "stat" : "Average",
            "period" : 60,
            "title" : "RDS Cluster READ IOPS",
            "yAxis" : {
              "left" : {
                "label" : "Count",
                "showUnits" : false
              }
            }
          }
        }

        # {
        #   "type" : "metric",
        #   "x" : 12,
        #   "y" : 0,
        #   "width" : 12,
        #   "height" : 6,
        #   "properties" : {
        #     "metrics" : [
        #       ["AWS/ECS", "CPUUtilization", "ClusterName", "your_cluster_name", "ServiceName", "your_service_name"],
        #       ["...", "MemoryUtilization"]
        #     ],
        #     "period" : 300,
        #     "title" : "ECS Service CPU and Memory Utilization"
        #   }
        # },
        # {
        #   "type" : "metric",
        #   "x" : 0,
        #   "y" : 7,
        #   "width" : 12,
        #   "height" : 6,
        #   "properties" : {
        #     "metrics" : [
        #       ["AWS/EFS", "ClientConnections", "FileSystemId", "your_file_system_id"]
        #     ],
        #     "period" : 300,
        #     "title" : "EFS Client Connections"
        #   }
        # },
        # {
        #   "type" : "metric",
        #   "x" : 12,
        #   "y" : 7,
        #   "width" : 12,
        #   "height" : 6,
        #   "properties" : {
        #     "metrics" : [
        #       ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "your_db_instance_identifier"],
        #       ["...", "CPUUtilization"],
        #       ["...", "ReadIOPS"],
        #       ["...", "WriteIOPS"]
        #     ],
        #     "period" : 300,
        #     "title" : "RDS Metrics"
        #   }
        # }
      ]
    }
  )
}
