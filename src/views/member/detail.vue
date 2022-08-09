<template>
  <div class="user-main-body" v-if="userData" v-loading="loading">
    <div class="float-left bg-white br-15 p-30">
      <back-bar class="mb-30" title="学员详情"></back-bar>
      <div class="user-info-box">
        <div class="user-base-info-box">
          <div class="user-avatar">
            <img :src="userData.avatar" width="80" height="80" />
          </div>
          <div class="user-info">
            <div class="user-nickname">{{ userData.nick_name }}</div>
            <div class="buttons">
              <el-link
                type="primary"
                class="real-profile"
                @click="updateMember(id)"
              >
                修改资料
              </el-link>
              <el-link
                type="primary"
                class="edit-profile"
                @click="
                  $router.push({
                    name: 'MemberProfile',
                    params: { userId: id },
                  })
                "
                >实名信息</el-link
              >
            </div>
          </div>
        </div>
        <div class="panel-info-box">
          <div class="panel-info-item">ID：{{ userData.id }}</div>
          <div class="panel-info-item">手机号：{{ userData.mobile }}</div>
          <div class="panel-info-item">
            最近登录时间：{{ userData.updated_at | dateFormat }}
          </div>
          <div class="panel-info-item">
            VIP： {{ userData.role ? userData.role.name : "" }}
          </div>
          <div class="panel-info-item">
            VIP到期时间：{{ userData.role_expired_at | dateFormat }}
          </div>
          <div class="panel-info-item">
            一级邀请人：
            <div style="flex: 1">
              {{ userData.invitor ? userData.invitor.nick_name : "" }}
            </div>
            <template v-if="userData.invitor">
              <div class="item">
                (截{{ userData.invite_user_expired_at | dateFormat }})
              </div>
            </template>
          </div>
          <div class="panel-info-item">
            邀请码：{{ userData.is_used_promo_code === 1 ? "已使用" : "—" }}
          </div>
          <div class="panel-info-item">
            推广抽成余额：{{ userData.invite_balance }}
          </div>
          <div class="panel-info-item">IP地址：{{ userData.register_ip }}</div>
          <div class="panel-info-item">
            注册区域： {{ userData.register_area }}
          </div>
          <div class="panel-info-item">
            账号状态：<template v-if="userData.is_lock === 1"
              ><span class="c-red">已冻结</span>
              <div class="item-box">
                <p-link
                  text="解冻"
                  type="primary"
                  p="member.update"
                  @click="lockMember()"
                ></p-link>
              </div>
            </template>
            <template v-else
              ><span class="c-green">正常</span>
              <div class="item-box">
                <p-link
                  text="冻结"
                  type="primary"
                  p="member.update"
                  @click="lockMember()"
                ></p-link>
              </div>
            </template>
          </div>
          <div class="panel-info-item">
            积分：
            <span>{{ userData.credit1 }}</span>
            <div class="item-box">
              <p-link
                text="变动"
                type="primary"
                p="member.credit1.change"
                @click="changeCredit()"
              ></p-link>
            </div>
          </div>
          <div class="panel-info-item">
            用户标签：
            <div
              style="width: 150px"
              v-if="userData.tags && userData.tags.length > 0"
            >
              <el-tag
                class="ml-5 mb-5"
                v-for="item in userData.tags"
                :key="item.id"
              >
                {{ item.name }}
              </el-tag>
            </div>
            <div class="item-box">
              <p-link
                text="修改"
                type="primary"
                p="member.tags"
                @click="changeTags()"
              ></p-link>
            </div>
          </div>
          <div class="panel-info-item large">
            备注：<template v-if="userData.remark">
              <div
                class="remark-text"
                style="width: 400px"
                v-html="userData.remark.remark"
              ></div>
            </template>
            <div class="item-box">
              <p-link
                text="修改"
                type="primary"
                p="member.remark.update"
                @click="changeRemark()"
              ></p-link>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 学员课程区域 -->
    <div class="float-left bg-white br-15 p-30 mt-30">
      <el-radio-group v-model="courseTabActive">
        <el-radio-button
          :label="item.key"
          v-for="item in courseTypes"
          :key="item.key"
          >{{ item.name }}</el-radio-button
        >
      </el-radio-group>

      <div class="float-left mt-30">
        <user-orders-comp
          :id="id"
          v-if="courseTabActive === 'order'"
        ></user-orders-comp>
        <user-credit1-comp
          :id="id"
          v-else-if="courseTabActive === 'credit1'"
        ></user-credit1-comp>
        <user-invite-comp
          :id="id"
          v-else-if="courseTabActive === 'invite'"
        ></user-invite-comp>
        <user-vod-watch-records-comp
          :id="id"
          v-else-if="courseTabActive === 'vod-watch-records'"
        ></user-vod-watch-records-comp>
        <user-video-watch-records-comp
          :id="id"
          v-else-if="courseTabActive === 'video-watch-records'"
        ></user-video-watch-records-comp>
        <user-live-watch-records-comp
          :id="id"
          v-else-if="courseTabActive === 'live'"
        ></user-live-watch-records-comp>
        <user-balance-records-comp
          :id="id"
          v-else-if="courseTabActive === 'balanceRecords'"
        ></user-balance-records-comp>
      </div>
    </div>
    <member-dialog
      :key="updateId"
      v-if="showAddWin"
      :text="tit"
      :id="updateId"
      @close="showAddWin = false"
      @success="successEvt"
    ></member-dialog>
    <credit-dialog
      :key="userData.id"
      v-if="showCreditWin"
      :id="userData.id"
      @close="showCreditWin = false"
      @success="successEvt"
    ></credit-dialog>
    <remark-dialog
      :key="userData.id"
      v-if="showRemarkWin"
      :id="userData.id"
      @close="showRemarkWin = false"
      @success="successEvt"
    ></remark-dialog>
    <tags-dialog
      :key="userData.id"
      v-if="showTagsWin"
      :id="userData.id"
      @close="showTagsWin = false"
      @success="successEvt"
    ></tags-dialog>
  </div>
</template>

<script>
import { mapState } from "vuex";
import UserLiveWatchRecordsComp from "./detail/live-watch-records.vue";
import UserOrdersComp from "./detail/orders.vue";
import UserCredit1Comp from "./detail/credit1.vue";
import UserInviteComp from "./detail/invite.vue";
import UserVodWatchRecordsComp from "./detail/vod-watch-records.vue";
import UserVideoWatchRecordsComp from "./detail/video-watch-records.vue";
import MemberDialog from "./components/member-dialog";
import CreditDialog from "./components/credit-dialog";
import RemarkDialog from "./components/remark-dialog";
import TagsDialog from "./components/tags-dialog";
import UserBalanceRecordsComp from "./detail/balanceRecords.vue";

export default {
  components: {
    UserOrdersComp,
    UserCredit1Comp,
    UserInviteComp,
    UserVodWatchRecordsComp,
    UserVideoWatchRecordsComp,
    UserLiveWatchRecordsComp,
    MemberDialog,
    CreditDialog,
    RemarkDialog,
    TagsDialog,
    UserBalanceRecordsComp,
  },
  data() {
    return {
      id: null,
      userData: null,
      loading: false,
      courseTabActive: "order",
      showAddWin: false,
      tit: null,
      updateId: null,
      showCreditWin: false,
      showRemarkWin: false,
      showTagsWin: false,
    };
  },
  computed: {
    ...mapState(["enabledAddons", "user"]),
    courseTypes() {
      let types = [
        {
          name: "订单明细",
          key: "order",
        },
      ];
      if (this.checkPermission("v2.member.courses")) {
        types.push({
          name: "录播课学习",
          key: "vod-watch-records",
        });
      }
      if (this.enabledAddons["Zhibo"]) {
        types.push({
          name: "直播课学习",
          key: "live",
        });
      }
      // if (this.enabledAddons["MeeduBooks"]) {
      //   types.push({
      //     name: "电子书",
      //     key: "books",
      //   });
      // }
      // if (this.enabledAddons["MeeduTopics"]) {
      //   types.push({
      //     name: "图文",
      //     key: "topics",
      //   });
      // }
      if (this.checkPermission("v2.member.videos")) {
        types.push({
          name: "单独订阅课时",
          key: "video-watch-records",
        });
      }
      types.push(
        ...[
          {
            name: "邀请明细",
            key: "invite",
          },
          {
            name: "积分明细",
            key: "credit1",
          },
        ]
      );
      if (
        this.enabledAddons["MultiLevelShare"] &&
        this.through("addons.MultiLevelShare.member.balanceRecords")
      ) {
        types.push({
          name: "邀请余额明细",
          key: "balanceRecords",
        });
      }

      return types;
    },
  },
  mounted() {
    this.id = this.$route.params.userId;

    this.getUser();
  },
  methods: {
    checkPermission(val) {
      return typeof this.user.permissions[val] !== "undefined";
    },
    updateMember(id) {
      this.tit = "编辑学员资料";
      this.updateId = id;
      this.showAddWin = true;
    },
    successEvt() {
      this.showAddWin = false;
      this.showCreditWin = false;
      this.showRemarkWin = false;
      this.showTagsWin = false;
      this.getUser();
    },
    changeCredit() {
      this.showCreditWin = true;
    },
    changeRemark() {
      this.showRemarkWin = true;
    },
    changeTags() {
      this.showTagsWin = true;
    },
    through(val) {
      return typeof this.user.permissions[val] !== "undefined";
    },
    getUser() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Member.Detail(this.id).then((res) => {
        this.userData = res.data.data;
        this.loading = false;
      });
    },
    lockMember() {
      let text = "冻结后此账号将无法登录，确认冻结？";
      let value = 1;
      if (this.userData.is_lock === 1) {
        text = "解冻后此账号将正常登录，确认解冻？";
        value = 0;
      }
      this.$confirm(text, "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          this.$api.Member.EditMulti({
            user_ids: [this.userData.id],
            field: "is_lock",
            value: value,
          })
            .then((res) => {
              this.$message.success(this.$t("common.success"));
              this.getUser();
            })
            .catch((e) => {
              this.$message.error(e.message);
            });
        })
        .catch(() => {});
    },
  },
};
</script>

<style lang="less" scoped>
.user-main-body {
  width: 100%;
  height: auto;
  float: left;
}

.user-info-box {
  width: 100%;
  height: auto;
  float: left;
  box-sizing: border-box;
  display: flex;
  justify-content: center;
  margin-top: 10px;
  flex-direction: column;

  .user-base-info-box {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding-bottom: 20px;
    border-bottom: 1px solid #f3f6f9;
    display: flex;
    flex-direction: row;

    .user-avatar {
      width: 80px;
      height: 80px;
      float: left;
      margin-right: 20px;
      img {
        width: 80px;
        height: 80px;
        border-radius: 50%;
      }
    }
    .user-info {
      width: auto;
      height: 80px;
      float: left;
      display: flex;
      flex-direction: column;
      .user-nickname {
        width: auto;
        height: 20px;
        float: left;
        font-size: 20px;
        font-weight: 600;
        color: #333333;
        line-height: 20px;
        margin-top: 13px;
      }
      .buttons {
        width: auto;
        height: 14px;
        float: left;
        display: flex;
        flex-direction: row;
        margin-top: 20px;
        .real-profile {
          margin-right: 20px;
        }
        .edit-profile {
          margin-right: 20px;
        }
      }
    }
  }
  .panel-info-box {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding-bottom: 20px;
    padding-top: 0px;

    display: flex;
    flex-wrap: wrap;
    .panel-info-item {
      display: flex;
      width: 325px;
      height: auto;
      font-size: 14px;
      font-weight: 400;
      color: #333333;
      box-sizing: border-box;
      padding: 0px 5px;
      margin-top: 30px;
      &.large {
        width: 650px;
      }
      .item {
        flex: 1;
        line-height: 20px;
        margin-left: 5px;
      }
      .item-box {
        flex: 1;
        line-height: 14px;
        margin-left: 20px;
      }
    }
  }
}

.user-extra-info-box {
  width: 100%;
  height: auto;
  float: left;
  box-sizing: border-box;
  padding: 30px;

  .info-label {
    font-weight: bold;
    color: #333;
    margin-right: 15px;
  }

  .info-value {
    color: rgba(0, 0, 0, 0.8);
  }
}
</style>
