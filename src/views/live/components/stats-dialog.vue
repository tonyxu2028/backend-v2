<template>
  <transition name="fade">
    <div class="mask" v-show="show">
      <div class="live-stats-box">
        <div class="live-stats-header">
          <span>直播统计</span>
          <img
            class="icon-close"
            @click="close()"
            src="@/assets/img/close.png"
          />
        </div>
        <div class="live-stats-body">
          <div class="stats-content" v-if="list">
            <div class="item border-right">
              <div class="item-name">直播时长</div>
              <div class="item-value">
                <duration-text :duration="list.duration"></duration-text>
              </div>
            </div>
            <div class="item border-right">
              <div class="item-name">聊天消息数</div>
              <div class="item-value">{{ list.count_chat }}</div>
            </div>
            <div class="item border-right">
              <div class="item-name">观看总人数</div>
              <div class="item-value">{{ list.count_watch_user }}</div>
            </div>
            <div class="item">
              <div class="item-name">学员平均观看时长</div>
              <div class="item-value">
                <duration-text
                  :duration="list.avg_watch_duration"
                ></duration-text>
              </div>
            </div>
          </div>
          <div class="chart-box">
            <div
              id="chartLine"
              ref="myChart"
              style="width: 970px; height: 260px"
            ></div>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
import DurationText from "@/components/duration-text";
export default {
  components: {
    DurationText,
  },
  props: ["id", "show"],
  data() {
    return {
      loading: false,
      list: null,
    };
  },
  watch: {
    show(val) {
      if (val) {
        this.getData();
      }
    },
  },
  mounted() {},
  beforeDestroy() {
    window.removeEventListener("resize", this.myChartResize, false);
  },
  methods: {
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Course.Live.Course.Video.Stats(this.id).then((res) => {
        this.loading = false;
        this.list = res.data;
        this.drawLineChart(res.data.online_user_count_per_minute);
      });
    },
    drawLineChart(obj) {
      let xset = [];
      let val = [];
      for (let key in obj) {
        xset.push(key);
        val.push(obj[key]);
      }
      const echarts = require("echarts");
      let myChart = echarts.init(document.getElementById("chartLine"));
      myChart.setOption({
        title: {
          text: "学员实时在线统计",
          left: "center",
          textStyle: { color: "#333", fontSize: 16 },
        },
        tooltip: {
          trigger: "axis",
        },
        xAxis: {
          type: "category",
          boundaryGap: false,
          data: xset,
        },
        yAxis: {
          type: "value",
        },
        series: [
          {
            name: "在线学员数",
            type: "line",
            // 设置折线图颜色
            itemStyle: {
              normal: {
                lineStyle: {
                  color: "#4876FF",
                },
              },
            },
            stack: "总量",
            data: val,
          },
        ],
      });

      window.addEventListener("resize", this.myChartResize, false);
    },
    myChartResize() {
      const echarts = require("echarts");
      let myChart = echarts.init(document.getElementById("chartLine"));
      myChart.resize();
    },
    close() {
      this.$emit("close");
    },
  },
};
</script>

<style lang="less" scoped>
.mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 2001;
  background-color: rgba(0, 0, 0, 0.5);
  .live-stats-box {
    position: absolute;
    top: 50%;
    left: 50%;
    width: 1000px;
    height: 490px;
    margin-top: -245px;
    margin-left: -500px;
    background-color: white;
    border-radius: 8px;
    animation: scaleBig 0.3s;
    .live-stats-header {
      width: 100%;
      height: auto;
      float: left;
      box-sizing: border-box;
      padding: 30px 15px;
      line-height: 18px;
      position: relative;
      display: flex;
      flex-direction: row;
      justify-content: space-between;
      span {
        flex: 1;
        font-size: 18px;
        font-weight: 600;
        color: #333333;
        line-height: 18px;
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
      }
      .icon-close {
        width: 18px;
        height: 18px;
        margin-right: 15px;
        cursor: pointer;
        &:hover {
          opacity: 0.8;
        }
      }
    }

    .live-stats-body {
      width: 100%;
      height: auto;
      min-height: 100px;
      float: left;
      box-sizing: border-box;
      padding: 0px 15px 30px 15px;
      .stats-content {
        width: 100%;
        height: auto;
        float: left;
        display: flex;
        justify-content: space-between;
        margin-bottom: 50px;
        .item {
          width: 25%;
          height: auto;
          display: flex;
          flex-direction: column;
          align-items: center;
          &.border-right {
            border-right: 1px solid #ccc;
          }
          .item-name {
            font-size: 18px;
            font-weight: 400;
            color: #666;
            line-height: 20px;
            margin-bottom: 15px;
          }
          .item-value {
            font-size: 26px;
            font-weight: 600;
            color: #333;
            line-height: 30px;
          }
        }
      }
      .chart-box {
        width: 100%;
        height: auto;
        float: left;
      }
    }
  }
}
</style>
