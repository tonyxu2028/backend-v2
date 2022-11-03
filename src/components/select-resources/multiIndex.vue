<template>
  <transition name="fade">
    <div class="meedu-dialog-mask" v-if="show">
      <div class="meedu-dialog-box">
        <div class="meedu-dialog-header">选择</div>
        <div class="meedu-dialog-body">
          <div class="float-left">
            <el-tabs v-model="activeResource">
              <el-tab-pane
                :label="item.name"
                :name="item.key"
                v-for="(item, index) in avaliableResources"
                :key="index"
              ></el-tab-pane>
            </el-tabs>
          </div>
          <div class="float-left">
            <vod-comp
              v-if="activeResource === 'vod'"
              :selected="selectedVod"
              @change="change"
            ></vod-comp>
            <live-comp
              v-else-if="activeResource === 'live'"
              :selected="selectedLive"
              @change="change"
            ></live-comp>
            <book-comp
              v-else-if="activeResource === 'book'"
              :selected="selectedBook"
              @change="change"
            ></book-comp>
            <paper-comp
              v-else-if="activeResource === 'paper'"
              :selected="selectedPaper"
              @change="change"
            ></paper-comp>
            <mock-paper-comp
              v-else-if="activeResource === 'mock_paper'"
              :selected="selectedMockPaper"
              @change="change"
            ></mock-paper-comp>
            <practice-comp
              v-else-if="activeResource === 'practice'"
              :selected="selectedPractice"
              @change="change"
            ></practice-comp>
            <vip-comp
              v-else-if="activeResource === 'vip'"
              :selected="selectedVip"
              @change="change"
            ></vip-comp>
          </div>
        </div>
        <div class="meedu-dialog-footer">
          <el-button type="primary" @click="confirm"> 确定 </el-button>
          <el-button @click="close" class="ml-30">取消</el-button>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
import { mapState } from "vuex";
import VodComp from "./components/multiVod.vue";
import LiveComp from "./components/multiLive.vue";
import BookComp from "./components/multiBook.vue";
import PaperComp from "./components/multiPaper.vue";
import MockPaperComp from "./components/multiMockPaper.vue";
import PracticeComp from "./components/multiPractice.vue";
import VipComp from "./components/multiVip.vue";

export default {
  components: {
    VodComp,
    LiveComp,
    BookComp,
    PaperComp,
    MockPaperComp,
    PracticeComp,
    VipComp,
  },
  props: [
    "show",
    "type",
    "selectedIds",
    "enabledResource",
    "selectedVod",
    "selectedLive",
    "selectedBook",
    "selectedPaper",
    "selectedMockPaper",
    "selectedPractice",
    "selectedVip",
  ],
  data() {
    return {
      selectedResult: null,
      activeResource: null,
    };
  },
  computed: {
    ...mapState(["enabledAddons"]),
    avaliableResources() {
      let resources = [];

      if (this.enabledResourceMap["vod"]) {
        resources.push({
          name: "录播",
          key: "vod",
        });
      }

      if (this.enabledResourceMap["live"] && this.enabledAddons["Zhibo"]) {
        resources.push({
          name: "直播",
          key: "live",
        });
      }
      if (this.enabledResourceMap["book"] && this.enabledAddons["MeeduBooks"]) {
        resources.push({
          name: "电子书",
          key: "book",
        });
      }
      if (this.enabledAddons["Paper"]) {
        if (this.enabledResourceMap["paper"]) {
          resources.push({
            name: "试卷",
            key: "paper",
          });
        }
        if (this.enabledResourceMap["mock_paper"]) {
          resources.push({
            name: "模拟卷",
            key: "mock_paper",
          });
        }
        if (this.enabledResourceMap["practice"]) {
          resources.push({
            name: "练习",
            key: "practice",
          });
        }
      }
      if (this.enabledResourceMap["vip"]) {
        resources.push({
          name: "VIP会员",
          key: "vip",
        });
      }
      return resources;
    },
    enabledResourceMap() {
      if (!this.enabledResource) {
        return {};
      }
      let items = this.enabledResource.split(",");
      let r = {};
      items.forEach((item) => {
        r[item] = 1;
      });

      return r;
    },
    resourceActive() {
      let r = null;
      if (this.enabledResourceMap["paper"] && !this.type) {
        r = "paper";
      } else {
        r = "vod";
      }
      return r;
    },
  },
  mounted() {
    this.activeResource = this.resourceActive;
  },
  methods: {
    close() {
      this.$emit("close");
    },
    confirm() {
      if (this.selectedResult === null || this.selectedResult.length === 0) {
        this.$message.warning("请先选择内容");
        return;
      }
      this.$emit("change", this.selectedResult);
    },
    change(result) {
      this.selectedResult = result;
    },
  },
};
</script>

<style lang="less" scoped>
.meedu-dialog-box {
  width: 900px !important;
  margin-left: -450px !important;
}
</style>
