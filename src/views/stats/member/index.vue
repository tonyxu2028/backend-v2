<template>
  <div class="el_content">
    <div class="el_top_row1">
      <div class="el_row_item">
        <div class="item_title">
          <span>今日学习学员数</span>
          <img class="icon" src="../../../assets/images/stats/icon.png" />
        </div>
        <p>{{ formatNumber(list.today_watch_count || 0, 0) }}</p>
        <div class="item_info">
          <span>昨日：{{ numberForHuman(list.yesterday_watch_count) }}</span>
          <span>
            较昨日：
            <strong :class="{ 'c-danger': todayWatchedRate < 0 }">
              {{ todayWatchedRate }}%
            </strong>
          </span>
        </div>
      </div>
      <div class="el_row_item">
        <div class="item_title">
          <span>今日新增学员</span>
          <img class="icon" src="../../../assets/images/stats/icon.png" />
        </div>
        <p>{{ formatNumber(list.today_count || 0, 0) }}</p>
        <div class="item_info">
          <span>昨日：{{ numberForHuman(list.yesterday_count) }}</span>
          <span>
            较昨日：
            <strong :class="{ 'c-danger': todayCountRate < 0 }">
              {{ todayCountRate }}%
            </strong>
          </span>
        </div>
      </div>
      <div class="el_row_item">
        <div class="item_title">
          <span>累计学员数</span>
          <img class="icon" src="../../../assets/images/stats/icon.png" />
        </div>
        <p>{{ formatNumber(list.user_count || 0, 0) }}</p>
        <div class="item_info">
          <span>昨日：{{ numberForHuman(list.yesterday_count) }}</span>
          <span>
            较上周：
            <strong :class="{ 'c-danger': weekUserRate < 0 }">
              {{ weekUserRate }}%
            </strong>
          </span>
          <span>
            较上月：
            <strong :class="{ 'c-danger': monthUserRate < 0 }">
              {{ monthUserRate }}%
            </strong>
          </span>
        </div>
      </div>
    </div>
    <div class="el_top_row2">
      <div class="el_row_left">
        <div class="header">
          <div class="item_title">
            <span>TOP10付费学员</span>
          </div>
          <div class="controls">
            <day-week-month @change="changeTimeUserTop"></day-week-month>
          </div>
        </div>
        <div class="float-left mt-15" v-loading="loading">
          <el-table
            :header-cell-style="{ background: '#f1f2f9' }"
            :data="users"
            class="float-left"
          >
            <el-table-column label="TOP10付费学员">
              <template slot-scope="scope">
                <span class="c-red" v-if="scope.row.user.length === 0"
                  >已删除</span
                >
                <span v-else>{{ scope.row.user.nick_name }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="count" label="支付订单数" width="250">
            </el-table-column>
            <el-table-column prop="total" label="支付总金额" width="250">
            </el-table-column>
          </el-table>
        </div>
        <div class="float-left mt-30 text-center">
          <el-pagination
            @size-change="paginationSizeChange"
            @current-change="paginationPageChange"
            :current-page="pagination.page"
            :page-sizes="[10, 20, 50, 100]"
            :page-size="pagination.size"
            layout="total, sizes, prev, pager, next, jumper"
            :total="total"
          >
          </el-pagination>
        </div>
      </div>
      <div class="el_row_right">
        <div class="el_row_right_item">
          <div class="header">
            <div class="item_title">
              <span>学员付费</span>
              <img class="icon" src="../../../assets/images/stats/icon.png" />
            </div>
            <div class="controls">
              <day-week-month @change="changeTimeUserGraph"></day-week-month>
            </div>
          </div>
          <div
            id="chartCircle"
            style="width: 100%; height: 273px; float: left; margin-top: 16px"
          ></div>
        </div>
        <div class="el_row_right_item">
          <div class="header">
            <div class="item_title">
              <span>学员注册渠道</span>
              <img class="icon" src="../../../assets/images/stats/icon.png" />
            </div>
            <div class="controls"></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import moment from "moment";
import { mapState, mapMutations } from "vuex";
import DayWeekMonth from "@/components/day-week-month";
const accounting = require("accounting");

export default {
  components: {
    DayWeekMonth,
  },
  data() {
    return {
      pageName: "stats-member-list",
      list: [],
      loading: false,
      users: [],
      total: 0,
      pagination: {
        page: 1,
        size: 10,
      },
      filter: {
        start_at: moment().format("YYYY-MM-DD"),
        end_at: moment().add(1, "days").format("YYYY-MM-DD"),
      },
      firstUserGraph: [],
    };
  },
  computed: {
    ...mapState(["enabledAddons", "user"]),
    todayWatchedRate() {
      return this.newSumrate(
        this.list.today_watch_count,
        this.list.yesterday_watch_count
      );
    },
    todayCountRate() {
      return this.newSumrate(this.list.today_count, this.list.yesterday_count);
    },
    weekUserRate() {
      return this.newSumrate(this.list.user_count, this.list.week_count);
    },
    monthUserRate() {
      return this.newSumrate(this.list.user_count, this.list.month_count);
    },
  },
  mounted() {
    this.getStatData();
    this.getUserTopData();
    this.getUserGraphData(
      moment().format("YYYY-MM-DD"),
      moment().add(1, "days").format("YYYY-MM-DD")
    );
  },
  beforeDestroy() {
    window.removeEventListener("resize", this.myChartResize, false);
  },
  methods: {
    ...mapMutations(["setEnabledAddons"]),
    formatNumber(num, fixed) {
      return accounting.formatNumber(num, fixed);
    },
    newSumrate(num1, num2) {
      if (typeof num1 !== "number" || typeof num2 !== "number") {
        return 0;
      }
      if (num2 === 0) {
        // 未有增长
        return 0;
      }
      if (num1 === 0) {
        //  => 100%
        return 100;
      }

      return parseInt((num2 / (num1 - num2)).toFixed(2) * 10000) / 100;
    },
    sumrate(num1, num2) {
      if (typeof num1 !== "number" || typeof num2 !== "number") {
        return 0;
      }
      if (num1 === 0) {
        // 今天未有增长
        return 0;
      }
      if (num2 === 0) {
        // 昨天无增长，今天有增长 => 100%
        return 100;
      }

      return parseInt(((num1 - num2) / num2).toFixed(2) * 10000) / 100;
    },
    numberForHuman(num) {
      if (num >= 100000000) {
        return (num / 100000000).toFixed(2) + "亿";
      } else if (num >= 10000000) {
        return (num / 10000000).toFixed(2) + "千万";
      } else if (num >= 1000000) {
        return (num / 1000000).toFixed(2) + "百万";
      } else if (num >= 10000) {
        return (num / 10000).toFixed(2) + "万";
      } else if (num >= 1000) {
        return (num / 1000).toFixed(2) + "千";
      }
      return num;
    },
    getStatData() {
      this.$api.Stats.Member.List().then((res) => {
        this.list = res.data;
      });
    },
    getUserTopData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.filter);
      Object.assign(params, this.pagination);
      this.$api.Stats.Member.UserTops(params).then((res) => {
        this.loading = false;
        this.users = res.data.data;
        this.total = res.data.total;
      });
    },
    paginationReset() {
      this.pagination.page = 1;
      this.filter.start_at = moment().format("YYYY-MM-DD");
      this.filter.end_at = moment().add(1, "days").format("YYYY-MM-DD");
      this.getUserTopData();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getUserTopData();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getUserTopData();
    },
    getUserGraphData(start_at, end_at) {
      let params = {
        start_at: start_at,
        end_at: end_at,
      };
      this.$api.Stats.Member.UserGraph(params).then((res) => {
        this.firstUserGraph = res.data["first-non-first"];

        this.drawChart(this.firstUserGraph);
      });
    },
    drawChart(params) {
      let num = params.first_count + params.non_first_count;
      let data = [
        {
          name: "首次付费用户",
          value: params.first_count,
        },
        {
          name: "非首次付费用户",
          value: params.non_first_count,
        },
      ];
      const echarts = require("echarts");
      let myChart = echarts.init(document.getElementById("chartCircle"));
      myChart.setOption({
        legend: [
          {
            selectedMode: true, // 图例选择的模式，控制是否可以通过点击图例改变系列的显示状态。默认开启图例选择，可以设成 false 关闭。
            bottom: "10%",
            left: "center",
            textStyle: {
              // 图例的公用文本样式。
              fontSize: 14,
              color: " #333333",
            },
            data: ["首次付费用户", "非首次付费用户"],
          },
        ],
        tooltip: {
          show: true, // 是否显示提示框
          formatter: "用户：{c}",
        },
        title: {
          text: "", //主标题
          left: "center", // 水平对齐方式
          bottom: 0,
          itemGap: 4, // 主副标题相隔间距
          textStyle: {
            // 主标题样式
            fontSize: 16,
            fontWeight: 400,
          },
        },
        series: [
          {
            name: "Access From",
            type: "pie",
            radius: ["40%", "60%"], // 环比 圈的大小
            center: ["50%", "40%"], // 图形在整个canvas中的位置
            color: ["#3A7BFF", "#FF9742"], // item的取色盘
            avoidLabelOverlap: false,
            itemStyle: {
              borderColor: "#fff", // 白边
              borderWidth: 2,
            },
            emphasis: {
              // 高亮item的样式
              disabled: true,
            },
            label: {
              show: true,
              position: "center",
              formatter: "付费" + num + "人", // 可以自定义，也可以{a}{b}{c}这种
            },
            labelLine: {
              show: false,
            },
            data: data,
          },
        ],
      });

      window.addEventListener("resize", this.myChartResize, false);
    },
    myChartResize() {
      const echarts = require("echarts");
      let myChart = echarts.init(document.getElementById("chartCircle"));
      myChart.resize();
    },
    changeTimeUserTop(start_at, end_at) {
      this.filter.start_at = start_at;
      this.filter.end_at = end_at;
      this.paginationPageChange(1);
    },
    changeTimeUserGraph(start_at, end_at) {
      this.getUserGraphData(start_at, end_at);
    },
  },
};
</script>
<style lang="less" scoped>
.el_content {
  min-width: 1169px;
  width: 100%;
  height: 100%;
  position: relative;
  display: flex;
  flex-direction: column;
  .el_top_row1 {
    width: 100%;
    height: 204px !important;
    display: flex;
    flex-direction: row;
    position: relative;
    .el_row_item {
      width: 32.5%;
      height: 204px !important;
      overflow: hidden;
      background: #ffffff;
      box-shadow: 0px 2px 4px 0px rgba(102, 102, 102, 0.05);
      border-radius: 8px;
      margin-right: 20px;
      padding: 20px;
      box-sizing: border-box;
      position: relative;
      display: flex;
      flex-direction: column;
      .item_title {
        width: 100%;
        padding-left: 10px;
        height: 16px;
        margin-bottom: 40px;
        display: flex;
        align-items: center;
        span {
          height: 16px;
          font-size: 16px;
          font-family: PingFangSC-Regular, PingFang SC;
          font-weight: 400;
          color: #666666;
          line-height: 16px;
        }
        .icon {
          width: 16px;
          height: 16px;
          margin-left: 10px;
        }
      }
      p {
        width: 100%;
        padding-left: 10px;
        height: 36px;
        font-size: 36px;

        font-weight: 600;
        color: #333333;
        line-height: 36px;
      }
      .item_info {
        margin-top: 30px;
        width: 100%;
        min-height: 42px;
        background: #f1f2f9;
        padding: 10px;
        box-sizing: border-box;
        overflow: hidden;
        display: flex;
        flex-direction: row;
        span {
          width: 50%;
          height: 22px;
          font-size: 16px;
          font-family: PingFangSC-Regular, PingFang SC;
          font-weight: 400;
          color: #666666;
          line-height: 22px;
          strong {
            color: #3ca7fa;
          }
        }
      }
    }
  }
  .el_top_row2 {
    width: 100%;
    float: left;
    height: auto;
    margin-top: 20px;
    display: flex;
    flex-direction: row;
    position: relative;
    .el_row_left {
      flex: 1;
      overflow: hidden;
      background: #ffffff;
      box-shadow: 0px 2px 4px 0px rgba(102, 102, 102, 0.05);
      border-radius: 8px;
      margin-right: 20px;
      padding: 16px 30px 30px 30px;
      box-sizing: border-box;
      position: relative;
      display: flex;
      flex-direction: column;
      margin-bottom: 20px;
      .header {
        width: 100%;
        height: auto;
        display: flex;
        flex-direction: row;
        align-items: center;
        .item_title {
          flex: 1;
          height: 16px;
          display: flex;
          align-items: center;
          span {
            height: 16px;
            font-size: 16px;
            font-weight: 600;
            color: #333333;
            line-height: 16px;
          }
          .icon {
            width: 16px;
            height: 16px;
            margin-left: 10px;
          }
        }
        .controls {
          width: 112px;
          height: 44px;
          display: flex;
          flex-direction: row;
        }
      }
    }
    .el_row_right {
      width: 32.5%;
      display: flex;
      flex-direction: column;
      margin-bottom: 20px;
      .el_row_right_item {
        width: 100%;
        height: 349px !important;
        overflow: hidden;
        background: #ffffff;
        box-shadow: 0px 2px 4px 0px rgba(102, 102, 102, 0.05);
        border-radius: 8px;
        margin-right: 20px;
        padding: 16px 30px 0px 30px;
        box-sizing: border-box;
        position: relative;
        display: flex;
        flex-direction: column;
        margin-bottom: 20px;
        &:last-child {
          margin-bottom: 0px;
        }
        .header {
          width: 100%;
          height: auto;
          display: flex;
          flex-direction: row;
          align-items: center;
          .item_title {
            flex: 1;
            height: 16px;
            display: flex;
            align-items: center;
            span {
              height: 16px;
              font-size: 16px;
              font-weight: 600;
              color: #333333;
              line-height: 16px;
            }
            .icon {
              width: 16px;
              height: 16px;
              margin-left: 10px;
            }
          }
          .controls {
            width: 112px;
            height: 44px;
            display: flex;
            flex-direction: row;
          }
        }
      }
    }
  }
}
</style>
