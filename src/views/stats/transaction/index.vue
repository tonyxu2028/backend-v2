<template>
  <div class="el_content">
    <div class="el_top_row1">
      <div class="el_row_item">
        <div class="item_title">
          <span>支付金额(元)</span>
        </div>
        <p>{{ formatNumber(list.today_paid_sum || 0, 0) }}</p>
        <div class="item_info">
          <span>昨日：{{ numberForHuman(list.yesterday_paid_sum) }}</span>
          <span>
            较昨日：
            <strong :class="{ 'c-danger': todayPaidRate < 0 }">
              {{ todayPaidRate }}%
            </strong>
          </span>
          <span>
            退款金额：
            <strong class="c-danger">
              {{ list.today_refund_sum }}
            </strong>
          </span>
        </div>
      </div>
      <div class="el_row_item">
        <div class="item_title">
          <span>支付订单数</span>
        </div>
        <p>{{ formatNumber(list.today_paid_count || 0, 0) }}</p>
        <div class="item_info">
          <span>昨日：{{ numberForHuman(list.yesterday_paid_count) }}</span>
          <span>
            较昨日：
            <strong :class="{ 'c-danger': todayPaidCountRate < 0 }">
              {{ todayPaidCountRate }}%
            </strong>
          </span>
          <span>
            退款订单数：
            <strong class="c-danger">
              {{ list.today_refund_count }}
            </strong>
          </span>
        </div>
      </div>
      <div class="el_row_item2">
        <div class="el_item">
          <div class="item_title">
            <span>客单价(元)</span>
          </div>
          <span class="el_item_num flex-1">
            {{ todayPaidSingle }}
          </span>
          <span class="el_item_increase">昨日：{{ yesterdayPaidSingle }}</span>
          <span class="el_item_increase">
            较昨日：
            <strong :class="{ 'c-danger': todayPaidCountRate < 0 }">
              {{ todayPaidSingleRate }}%
            </strong>
          </span>
        </div>
        <div class="el_item">
          <div class="item_title">
            <span>支付人数</span>
          </div>
          <span class="el_item_num flex-1">
            {{ formatNumber(list.today_paid_user_count, 0) }}
          </span>
          <span class="el_item_increase"
            >昨日：{{ numberForHuman(list.yesterday_paid_user_count) }}</span
          >
          <span class="el_item_increase">
            较昨日：
            <strong :class="{ 'c-danger': todayPaidUserCountRate < 0 }">
              {{ todayPaidUserCountRate }}%
            </strong>
          </span>
        </div>
      </div>
    </div>
    <div class="el_top_row2">
      <div class="el_row_left">
        <div class="header">
          <div class="item_title">
            <span>交易过程统计</span>
          </div>
        </div>
        <div class="data-box">
          <div class="data-item">
            <div class="tit">
              <span>确认下单数</span>
            </div>
            <div class="num">{{ formatNumber(list.today_count, 0) }}</div>
            <div class="info mb-30">
              昨日：{{ numberForHuman(list.yesterday_count) }}
            </div>
            <div class="info">
              较昨日：<span :class="{ 'c-danger': todayCountRate < 0 }"
                >{{ todayCountRate }}%</span
              >
            </div>
          </div>
          <div class="row-line"></div>
          <div class="data-item">
            <div class="tit">
              <span>支付订单数</span>
            </div>
            <div class="num">{{ formatNumber(list.today_paid_count, 0) }}</div>
            <div class="info mb-30">
              昨日：{{ numberForHuman(list.yesterday_paid_count) }}
            </div>
            <div class="info">
              较昨日：<span :class="{ 'c-danger': todayPaidCountRate < 0 }"
                >{{ todayPaidCountRate }}%</span
              >
            </div>
          </div>
          <div class="row-line"></div>
          <div class="data-item">
            <div class="tit">
              <span>支付转化率</span>
            </div>
            <div class="num">{{ todayPaidConversion }}%</div>
            <div class="info mb-30">昨日：{{ yesterdayPaidConversion }}%</div>
            <div class="info">
              较昨日：<span :class="{ 'c-danger': todayPaidConversionRate < 0 }"
                >{{ todayPaidConversionRate }}%</span
              >
            </div>
          </div>
        </div>
      </div>
      <div class="el_row_right">
        <div class="el_row_right_item">
          <div class="header">
            <div class="item_title">
              <span>TOP5支付金额</span>
            </div>
            <div class="controls">
              <day-week-month @change="changeTimePaid"></day-week-month>
            </div>
          </div>
          <div class="top-list">
            <div class="list-item" v-for="item in topData" :key="item.goods_id">
              <div class="list-item-name">{{ item.goods_name }}</div>
              <div class="list-item-sum">{{ item.orders_paid_sum }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="el_top_row3">
      <div class="el_row_item">
        <div class="header">
          <div class="title">
            <span>交易分析</span>
          </div>
          <div class="controls">
            <day-week-month
              :active="true"
              @change="changeTimeTransactionGraph"
            ></day-week-month>
          </div>
        </div>
        <el-col class="formbox">
          <div
            id="chartLine"
            ref="myChart"
            style="
              width: 100%;
              height: 252px;
              margin-left: -30px;
              margin-top: 20px;
            "
          ></div>
        </el-col>
      </div>
    </div>
  </div>
</template>
<script>
import moment from "moment";
import { mapState } from "vuex";
import DayWeekMonth from "@/components/day-week-month";
const accounting = require("accounting");

export default {
  components: {
    DayWeekMonth,
  },
  data() {
    return {
      pageName: "stats-transaction-list",
      list: [],
      loading: false,
      topData: [],
      total: 0,
      pagination: {
        page: 1,
        size: 5,
      },
      filter: {
        start_at: moment().format("YYYY-MM-DD"),
        end_at: moment().add(1, "days").format("YYYY-MM-DD"),
      },
      firstTransactionGraph: [],
    };
  },
  computed: {
    ...mapState(["enabledAddons", "user"]),
    todayPaidRate() {
      return this.newSumrate(
        this.list.today_paid_sum,
        this.list.yesterday_paid_sum
      );
    },
    todayPaidCountRate() {
      return this.newSumrate(
        this.list.today_paid_count,
        this.list.yesterday_paid_count
      );
    },
    todayPaidUserCountRate() {
      return this.newSumrate(
        this.list.today_paid_user_count,
        this.list.yesterday_paid_user_count
      );
    },
    todayCountRate() {
      return this.newSumrate(this.list.today_count, this.list.yesterday_count);
    },
    todayPaidSingle() {
      if (
        typeof this.list.today_paid_sum !== "number" ||
        typeof this.list.today_paid_user_count !== "number"
      ) {
        return 0;
      }
      if (this.list.today_paid_user_count === 0) {
        return 0;
      }

      return parseInt(
        this.list.today_paid_sum / this.list.today_paid_user_count
      );
    },
    yesterdayPaidSingle() {
      if (
        typeof this.list.yesterday_paid_sum !== "number" ||
        typeof this.list.yesterday_paid_user_count !== "number"
      ) {
        return 0;
      }
      if (this.list.yesterday_paid_user_count === 0) {
        return 0;
      }

      return parseInt(
        this.list.yesterday_paid_sum / this.list.yesterday_paid_user_count
      );
    },
    todayPaidSingleRate() {
      return this.newSumrate(this.todayPaidSingle, this.yesterdayPaidSingle);
    },
    todayPaidConversion() {
      if (
        typeof this.list.today_paid_count !== "number" ||
        typeof this.list.today_count !== "number"
      ) {
        return 0;
      }
      if (this.list.today_count === 0) {
        return 0;
      }

      return (
        parseInt(
          (this.list.today_paid_count / this.list.today_count).toFixed(2) *
            10000
        ) / 100
      );
    },
    yesterdayPaidConversion() {
      if (
        typeof this.list.yesterday_paid_count !== "number" ||
        typeof this.list.yesterday_count !== "number"
      ) {
        return 0;
      }
      if (this.list.yesterday_count === 0) {
        return 0;
      }

      return (
        parseInt(
          (this.list.yesterday_paid_count / this.list.yesterday_count).toFixed(
            2
          ) * 10000
        ) / 100
      );
    },
    todayPaidConversionRate() {
      return this.newSumrate(
        this.todayPaidConversion,
        this.yesterdayPaidConversion
      );
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
    this.getTopData();
    this.getTransactionGraphData(
      moment().subtract(6, "days").format("YYYY-MM-DD"),
      moment().add(1, "days").format("YYYY-MM-DD")
    );
  },
  beforeDestroy() {
    window.removeEventListener("resize", this.myChartResize, false);
  },
  methods: {
    formatNumber(num, fixed) {
      return accounting.formatNumber(num, fixed);
    },
    sumrate(num1, num2) {
      if (typeof num1 !== "number" || typeof num2 !== "number") {
        return 0;
      }
      if (num2 === num1) {
        return 0;
      }
      if (num2 === 0) {
        return 100;
      }

      return parseInt((num2 / (num1 - num2)).toFixed(2) * 10000) / 100;
    },
    newSumrate(num1, num2) {
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
      this.$api.Stats.Transaction.List().then((res) => {
        this.list = res.data;
      });
    },
    getTopData() {
      let params = {};
      Object.assign(params, this.filter);
      Object.assign(params, this.pagination);
      this.$api.Stats.Content.List(params).then((res) => {
        this.topData = res.data.data;
        this.total = res.data.total;
      });
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getTopData();
    },
    getTransactionGraphData(start_at, end_at) {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {
        start_at: start_at,
        end_at: end_at,
      };
      this.$api.Stats.Transaction.TransactionGraph(params).then((res) => {
        this.firstTransactionGraph = res.data;
        this.drawLineChart(res.data);
        this.loading = false;
      });
    },
    drawLineChart(params) {
      const echarts = require("echarts");
      let myChart = echarts.init(document.getElementById("chartLine"));
      myChart.setOption({
        tooltip: {
          trigger: "axis",
        },
        legend: {
          data: ["支付金额", "支付订单数", "支付人数", "客单价"],
          x: "right",
        },
        grid: {
          left: "3%",
          right: "4%",
          bottom: "3%",
          containLabel: true,
        },
        xAxis: {
          type: "category",
          boundaryGap: false,
          data: this.changeObjectKey(params.paid_sum),
        },
        yAxis: {
          type: "value",
        },
        series: [
          {
            name: "支付金额",
            type: "line",
            data: this.changeObject(params.paid_sum),
          },
          {
            name: "支付订单数",
            type: "line",
            data: this.changeObject(params.paid_count),
          },
          {
            name: "支付人数",
            type: "line",
            data: this.changeObject(params.paid_user_count),
          },
          {
            name: "客单价",
            type: "line",
            data: this.changeObject(params.paid_avg_charge),
          },
        ],
      });

      window.addEventListener("resize", this.myChartResize, false);
    },
    changeObject(obj) {
      let data = Object.values(obj);
      return data;
    },
    changeObjectKey(obj) {
      var arr = [];
      for (let i in obj) {
        arr.push(i); //返回键名
      }
      return arr;
    },
    myChartResize() {
      const echarts = require("echarts");
      let myChart = echarts.init(document.getElementById("chartLine"));
      myChart.resize();
    },
    changeTimePaid(start_at, end_at) {
      this.filter.start_at = start_at;
      this.filter.end_at = end_at;
      this.paginationPageChange(1);
    },
    changeTimeTransactionGraph(start_at, end_at) {
      this.getTransactionGraphData(start_at, end_at);
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
    .el_row_item2 {
      width: 32.6%;
      height: 204px !important;
      overflow: hidden;
      position: relative;
      display: flex;
      flex-direction: column;
      .el_item {
        width: 100%;
        height: 92px;
        background: #ffffff;
        box-shadow: 0px 2px 4px 0px rgba(102, 102, 102, 0.05);
        border-radius: 8px;
        padding-left: 30px;
        padding-right: 30px;
        overflow: hidden;
        box-sizing: border-box;
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 20px;
        .item_title {
          width: 110px;
          height: 16px;
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
        .el_item_num {
          margin-left: 15px;
          flex: 1;
          height: 36px;
          font-size: 36px;
          font-family: PingFangSC-Semibold, PingFang SC;
          font-weight: 600;
          color: #333333;
          line-height: 36px;
          text-align: left;
        }
        .el_item_increase {
          width: 135px;
          strong {
            color: #3ca7fa;
          }
        }
      }
      .el_item:last-of-type {
        margin-bottom: 0px;
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
      padding: 30px;
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
      .data-box {
        width: 100%;
        height: auto;
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        margin-top: 40px;
        .row-line {
          width: 105px;
          height: 1px;
          background: #cccccc;
          margin-top: 7px;
        }
        .data-item {
          width: auto;
          position: relative;
          display: flex;
          flex-direction: column;
          .tit {
            width: 100%;
            height: 16px;
            display: flex;
            align-items: center;
            span {
              height: 16px;
              font-size: 16px;
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
          .num {
            width: 100%;
            font-size: 36px;
            font-weight: 600;
            color: #333333;
            line-height: 36px;
            margin-top: 40px;
            margin-bottom: 40px;
          }
          .info {
            width: 100%;
            font-size: 16px;
            font-weight: 400;
            color: #666666;
            line-height: 16px;
            span {
              color: #3ca7fa;
            }
          }
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
        .top-list {
          width: 100%;
          display: flex;
          flex-direction: column;
          margin-top: 30px;
          .list-item {
            width: 100%;
            height: auto;
            display: flex;
            flex-direction: row;
            align-items: center;
            margin-bottom: 30px;
            .list-item-name {
              width: 300px;
              height: 14px;
              font-size: 14px;
              font-weight: 400;
              color: #666666;
              line-height: 14px;
              overflow: hidden; //溢出隐藏
              white-space: nowrap; //禁止换行
              text-overflow: ellipsis; //...
            }
            .list-item-sum {
              flex: 1;
              font-size: 14px;
              font-weight: 400;
              color: #333333;
              line-height: 14px;
              text-align: right;
            }
          }
        }
      }
    }
  }
  .el_top_row3 {
    width: 100%;
    height: auto;
    display: flex;
    flex-direction: row;
    position: relative;
    .el_row_item {
      width: 100%;
      height: auto;
      overflow: hidden;
      background: #ffffff;
      box-shadow: 0px 2px 4px 0px rgba(102, 102, 102, 0.05);
      border-radius: 8px;
      padding: 16px 30px 30px 30px;
      box-sizing: border-box;
      position: relative;
      display: flex;
      flex-direction: column;
      margin-bottom: 20px;
      .header {
        width: 100%;
        display: flex;
        flex-direction: row;
        position: relative;
        align-items: center;
        justify-content: space-between;
        .title {
          height: 16px;
          font-size: 16px;
          font-weight: 600;
          color: #333333;
          line-height: 16px;
        }
      }
    }
  }
}
</style>
